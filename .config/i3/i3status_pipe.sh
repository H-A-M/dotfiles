#!/bin/bash
# TL;DR this finds the end of the i3bar stream and tacks a new thing on there.

# Modified from:
# https://gist.github.com/slowbro/922baa4959006ca31ac7af03acb54245


color_good="#997373"
color_bad="#c95454"
color_degraded="#006298"

[[ "$1" != "" ]] \
    && cmd="i3status --config $1" \
    || cmd="i3status"


linehead=""
json_prpend=""
mkelement() {
[[ -z "$2" ]] \
    && json_prepend+="{\"full_text\":\"`echo -n $1`\"}," \
    || json_prepend+="{\"color\":\"$2\",\"full_text\":\"`echo -n $1`\"},"
}


$cmd | while :
do
    read line
    if [[ "$line" =~ ^,?\[\{  ]];then
        nline=`echo $line | sed 's/^,\?\[//'`
        [[ "$line" =~ ^, ]] && linehead=","


        # print track
        if [[ "`~/.bin/track.lua -- \"%B\"`" == "true" ]];then
            mkelement "`~/.bin/track.lua -- \"▶ %n %t/%T ♫ %v\"`" "$color_good"
        else
            [[ "`~/.bin/track.lua -- \"%n\"`" != "No Track" ]] \
                && mkelement "`~/.bin/track.lua -- \"▮▮ %n %t/%T ♫ %v\"`" \
                || mkelement "`~/.bin/track.lua -- \"♫ %v\"`"
        fi
        
        # print uptime
        mkelement "`lr -e '
            fd=io.popen("uptime -p","r")
            if not fd then return end
            s=string.gsub(fd:read(), "(%a+)", function(a)
                return string.upper(string.sub(a,1,1))..string.sub(a,2,#a)
            end)
            io.stdout:write(s)'`"

        # print number of packages out of date, see ~/.config/systemd/user/updatechecker.service and .timer
        if [[ -f ~/.package_updates ]];then
            [[ "`cat ~/.package_updates`" -gt 0 ]] \
                && mkelement "Updates: `cat ~/.package_updates`" "$color_good" \
                || mkelement "Updates: `cat ~/.package_updates`"
        fi
        
        # print memory, if swap is in use, change color
        [[ "`~/.bin/memory.lua -- \"%U\"`" -gt 0 ]] \
            && mkelement "`~/.bin/memory.lua --format=\"%f MB\" --D=mega`" "$color_good" \
            || mkelement "`~/.bin/memory.lua --format=\"%f MB\" --D=mega`"


        # print CPU temperature 0-1, if core 1 exceeds 65 degrees, change color
        [[ "`~/.bin/temps.lua -- \"%core1\"`" -ge 65 ]] \
            && mkelement "`~/.bin/temps.lua -- \"%core0°C %core1°C\"`" "$color_bad" \
            || mkelement "`~/.bin/temps.lua -- \"%core0°C %core1°C\"`"


        echo "$linehead[$json_prepend$nline" || exit 1
        json_prepend=""
    else
        echo $line
    fi
done

