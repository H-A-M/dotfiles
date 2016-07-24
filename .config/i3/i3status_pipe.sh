#!/bin/bash
# TL;DR this finds the end of the i3bar stream and tacks a new thing on there.

# Modified from:
# https://gist.github.com/slowbro/922baa4959006ca31ac7af03acb54245


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
                json_prepend+="{\"name\":\"run_watch\",\"instance\":\"any\",\"color\":\"$2\",\"full_text\":\"`echo -n $1`\"},"
            }
            
            # print memory
            # mkelement "`~/.bin/memory.lua --format=\"%u/%t\" -d`" "#ffffff"


            # print track
            if [[ "`~/.bin/track.lua -- \"%B\"`" == "true" ]];then
                mkelement "`~/.bin/track.lua -- \"▶ %n %t/%T ♫ %v\"`" "#d79921"
            else
                [[ "`~/.bin/track.lua -- \"%n\"`" != "No Track" ]] \
                    && mkelement "`~/.bin/track.lua -- \"▮▮ %n %t/%T ♫ %v\"`" "#ffffff" \
                    || mkelement "`~/.bin/track.lua -- \"♫ %v\"`" "#ffffff"
            fi

            echo "$LINEHEAD[$json_prepend$nline" || exit 1

            # Why do I have to do this when it's getting set to a blank string before use on every iteration?
            unset json_prepend
        else
            echo $line
        fi
done

