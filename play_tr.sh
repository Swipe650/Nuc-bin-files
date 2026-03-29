#!/bin/bash

touch ~/.tr

if [[ -f ~/.lbc ]]; then rm ~/.lbc & touch ~/.tr
fi

radiotray-ng &
sleep 3
mute () { "$HOME/bin/mute_radiotray-ng" -m /usr/bin/radiotray-ng && rename_xmuted; }
unmute () { "$HOME/bin/mute_radiotray-ng" -u /usr/bin/radiotray-ng && rename_muted; }
rename_xmuted () { if [ -f "$HOME/.conky/xmuted.png" ]; then { mv "$HOME/.conky/xmuted.png" "$HOME/.conky/muted.png"; } fi }
rename_muted () { if [ -f "$HOME/.conky/muted.png" ]; then { mv "$HOME/.conky/muted.png" "$HOME/.conky/xmuted.png"; } fi }
talkradio () { qdbus com.github.radiotray_ng /com/github/radiotray_ng com.github.radiotray_ng.play_station Imported 'TalkRadio' ; }
setvol () { qdbus com.github.radiotray_ng /com/github/radiotray_ng com.github.radiotray_ng.set_volume 35 ; }
unmute_pwctl () { wpctl set-mute $(wpctl status | awk '/Streams:/ {f=1; next} f && /radiotray-ng/ {print $1; exit}' | tr -d '.') 0; } 

setvol
talkradio
sleep 3
unmute_pwctl
unmute
rename_muted
