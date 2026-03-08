#!/bin/bash

MUTED="$HOME/.conky/muted.png"
XMUTED="$HOME/.conky/xmuted.png"

state=$(qdbus com.github.radiotray_ng /com/github/radiotray_ng com.github.radiotray_ng.get_player_state)

if echo "$state" | grep -q '"mute" *: *false'; then
    # Not muted
    [ -f "$XMUTED" ] && mv "$XMUTED" "$MUTED"
    #wpctl set-mute 59 1
else
    # Muted
    [ -f "$MUTED" ] && mv "$MUTED" "$XMUTED"
    #wpctl set-mute 59 0
fi   

#qdbus com.github.radiotray_ng /com/github/radiotray_ng com.github.radiotray_ng.mute;
wpctl set-mute 59 toggle

