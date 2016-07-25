#!/bin/bash
# TL;DR this finds the end of the i3bar stream and tacks a new thing on there.

# Modified from:
# https://gist.github.com/slowbro/922baa4959006ca31ac7af03acb54245


color_good="#d79921"
color_bad="#fb4334"
color_degraded="#006298"


if [[ "$1" != "" ]];then
    cmd="i3status --config $1"
else
    cmd="i3status"
fi

LINEHEAD=""
$cmd | while :
do
    read line
    if [[ "$line" =~ ^,?\[\{  ]];then
        nline=`echo $line | sed 's/^,\?\[//'`
        if [[ "$line" =~ ^, ]];then
            LINEHEAD=","
        fi

        json_prpend=""
        mkelement() {
            [[ -z "$2" ]] \
                && json_prepend+="{\"full_text\":\"`echo -n $1`\"}," \
                || json_prepend+="{\"color\":\"$2\",\"full_text\":\"`echo -n $1`\"},"
        }
        
        # print memory
        # mkelement "`~/.bin/memory.lua --format=\"%u/%t\" -d`" "#ffffff"

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
            [[ "`cat ~/.package_updates`" -ge 1 ]] \
                && mkelement "`echo -n \"Updates: \"` `cat ~/.package_updates`" "$color_bad" \
                || mkelement "`echo -n \"Updates: \"` `cat ~/.package_updates`"
        fi

        # print CPU temperature 0-1, if core 1 exceeds 65 degrees, change the color to red
        [[ "`~/.bin/temps.lua -- \"%core1\"`" -ge 65 ]] \
            && mkelement "`~/.bin/temps.lua -- \"%core0°C %core1°C\"`" "$color_bad" \
            || mkelement "`~/.bin/temps.lua -- \"%core0°C %core1°C\"`"


        echo "$LINEHEAD[$json_prepend$nline" || exit 1
        # Why do I have to do this when it's getting set to a blank string before use on every iteration?
        unset json_prepend
    else
        echo $line
    fi
done

