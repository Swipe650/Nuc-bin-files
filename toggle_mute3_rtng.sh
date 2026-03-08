#!/bin/bash

CONKY_DIR="$HOME/.conky"
TIMER_FILE="$HOME/.conkytimer"

###############################################################################
# MUTE / UNMUTE
###############################################################################

mute_app() {
    ~/bin/radiotray_mute_control.sh mute && toggle_icon muted
}

unmute_app() {
    ~/bin/radiotray_mute_control.sh unmute && toggle_icon unmuted
}

toggle_icon() {
    case "$1" in
        muted)
            [ -f "$CONKY_DIR/xmuted.png" ] && mv "$CONKY_DIR/xmuted.png" "$CONKY_DIR/muted.png"
        ;;
        unmuted)
            [ -f "$CONKY_DIR/muted.png" ] && mv "$CONKY_DIR/muted.png" "$CONKY_DIR/xmuted.png"
        ;;
    esac
}

###############################################################################
# OSD
###############################################################################

show_osd() {
    vol=$(amixer -D pulse get Master | awk -F 'Left:|[][]' 'BEGIN{RS=""}{print $3}')
    qdbus org.kde.plasmashell /org/kde/osdService \
        org.kde.osdService.volumeChanged "${vol::-1}"
}

show_muted_osd() {
    qdbus org.kde.plasmashell /org/kde/osdService \
        org.kde.osdService.volumeChanged 0
}

###############################################################################
# CONKY TIMER
###############################################################################

conky_timer() {
    local seconds=$1

    for ((i=seconds;i>0;i--)); do
        printf "                  %s\n" "$i" > "$TIMER_FILE"
        sleep 1
    done

    rm -f "$TIMER_FILE"
    touch "$TIMER_FILE"
}

###############################################################################
# TOP OF HOUR ADBREAK
###############################################################################

top_of_hour_adbreak() {
    local length=$1

    mute_app
    show_muted_osd
    conky_timer "$length"
    unmute_app
    show_osd
    exit
}

check_top_of_hour() {

    local minute
    minute=$(date +%M)

    stations=(
        ".tr:01 02 03 04:50"
        ".tr:28 29 30 31 32 33 34 35 36 37:150"
        ".lbc:00 01 02 03 04 05 06:30"
    )

    for s in "${stations[@]}"; do

        IFS=':' read -r file times adlength <<< "$s"

        if [[ -f "$file" && " $times " =~ " $minute " ]]; then
            top_of_hour_adbreak "$adlength"
        fi
    done
}

###############################################################################
# DEFAULT ADBREAK
###############################################################################

check_off_peak() {

    local time
    time=$(date +%H%M)
    
    if [[ "$time" -gt 1900 || "$time" -lt 0600 ]] && [[ $st != "GB News" ]]; then
        timeout=170
    fi
}

default_adbreak() {

    if [[ $st == "GB News" ]]; then timeout=225; else timeout=185; fi
    check_off_peak
    conky_timer "$timeout"
}

###############################################################################
# MAIN
###############################################################################

st=$(qdbus com.github.radiotray_ng /com/github/radiotray_ng com.github.radiotray_ng.get_player_state | jq -r '.station')
check_top_of_hour
mute_app
show_muted_osd
default_adbreak
unmute_app
show_osd
