#!/bin/bash

MUTED="$HOME/.conky/muted.png"
XMUTED="$HOME/.conky/xmuted.png"

state=$(qdbus com.github.radiotray_ng /com/github/radiotray_ng com.github.radiotray_ng.get_player_state)

if echo "$state" | grep -q '"mute" *: *false'; then
    # Not muted
    [ -f "$XMUTED" ] && mv "$XMUTED" "$MUTED"
else
    # Muted
    [ -f "$MUTED" ] && mv "$MUTED" "$XMUTED"
fi

qdbus com.github.radiotray_ng /com/github/radiotray_ng com.github.radiotray_ng.mute;
