#!/bin/bash

###############################################################################
# GET RADIOTRAY STATE
###############################################################################

radiotray_state() {
    qdbus com.github.radiotray_ng /com/github/radiotray_ng \
    com.github.radiotray_ng.get_player_state
}

radiotray_is_muted() {
    radiotray_state | jq -e '.mute == true' >/dev/null
}

radiotray_is_unmuted() {
    radiotray_state | jq -e '.mute == false' >/dev/null
}

###############################################################################
# GET PIPEWIRE STREAM ID
###############################################################################

radiotray_stream() {
    wpctl status | awk '
        /Streams:/ {f=1; next}
        f && /radiotray-ng/ {print $1; exit}
    ' | tr -d '.'
}

###############################################################################
# MUTE / UNMUTE FUNCTIONS
###############################################################################

mute_radiotray() {

    if radiotray_is_unmuted; then
        echo "Muting RadioTray-NG"
        wpctl set-mute "$(radiotray_stream)" toggle
    else
        echo "RadioTray-NG already muted"
    fi
}

unmute_radiotray() {

    if radiotray_is_muted; then
        echo "Unmuting RadioTray-NG"
        wpctl set-mute "$(radiotray_stream)" toggle
    else
        echo "RadioTray-NG already unmuted"
    fi
}

###############################################################################
# COMMAND HANDLER
###############################################################################

case "$1" in
    mute)
        mute_radiotray
    ;;
    unmute)
        unmute_radiotray
    ;;
    status)
        if radiotray_is_muted; then
            echo "Muted"
        else
            echo "Unmuted"
        fi
    ;;
    *)
        echo "Usage: $0 {mute|unmute|status}"
    ;;
esac
