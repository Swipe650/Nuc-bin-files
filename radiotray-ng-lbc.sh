#!/bin/sh

touch ~/.lbc

if [[ -f ~/.tr ]]; then rm ~/.tr & touch ~/.lbc
fi

radiotray-ng &
sleep 1
setvol () { qdbus com.github.radiotray_ng /com/github/radiotray_ng com.github.radiotray_ng.set_volume 47 ; }
mute () { "$HOME/bin/mute_radiotray-ng" -m /usr/bin/radiotray-ng && rename_xmuted; }
unmute () { "$HOME/bin/mute_radiotray-ng" -u /usr/bin/radiotray-ng && rename_muted; }
rename_xmuted () { if [ -f "$HOME/.conky/xmuted.png" ]; then { mv "$HOME/.conky/xmuted.png" "$HOME/.conky/muted.png"; } fi }
rename_muted () { if [ -f "$HOME/.conky/muted.png" ]; then { mv "$HOME/.conky/muted.png" "$HOME/.conky/xmuted.png"; } fi }
setvol

qdbus com.github.radiotray_ng /com/github/radiotray_ng com.github.radiotray_ng.play_station Imported 'LBC UK'  ; sleep 3  ;  ~/.conky/conkyradiotray-ng/onair
unmute
