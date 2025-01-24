#!/bin/bash

# Generic mute/unmute function
mute_app() { "$HOME/bin/mute_radiotray-ng" -m "$1" && rename_muted_file; } 
unmute_app() { "$HOME/bin/mute_radiotray-ng" -u "$1" && rename_unmuted_file; } 

rename_muted_file() {
    if [ -f "$HOME/.conky/xmuted.png" ]; then
        mv "$HOME/.conky/xmuted.png" "$HOME/.conky/muted.png"
    fi
}

rename_unmuted_file() {
    if [ -f "$HOME/.conky/muted.png" ]; then
        mv "$HOME/.conky/muted.png" "$HOME/.conky/xmuted.png"
    fi
}

# Conky countdown timer
conkytimer() {
    sec=$1
    for (( i = 0; i < sec; i++ )); do
        timer=$((sec-i))
        echo "                  ${timer}" > ~/.conkytimer
        sleep 1
    done
    rm -f ~/.conkytimer
    touch ~/.conkytimer
}

# Get current volume level and show OSD dialog
show_osd_dialog() {
    vollevel=$(amixer -D pulse get Master | awk -F 'Left:|[][]' 'BEGIN {RS=""}{ print $3 }')
    qdbus org.kde.plasmashell /org/kde/osdService org.kde.osdService.volumeChanged "${vollevel::-1}"
}

# Mute/unmute actions and top-of-the-hour dialog
top_of_the_hour_dialog() {
    mute_app /usr/bin/radiotray-ng
    mute_app /usr/bin/vlc
    qdbus org.kde.plasmashell /org/kde/osdService org.kde.osdService.volumeChanged 0
    conkytimer "$adlength"
    unmute_app /usr/bin/radiotray-ng
    unmute_app /usr/bin/vlc
    show_osd_dialog
}

# Check top of the hour conditions
check_top_of_the_hour() {
    currenttime=$(date +%M)
    stations=(
        ".tr:TalkRadio:01 02 03 04:45"
        ".tr:TalkRadio:29 30 31 32 33 34 35 36 37:170"
        ".lbc:LBC UK:00 01 02 03 04 05 06:30"
    )

    for station in "${stations[@]}"; do
        IFS=':' read -r file station_name times adlength_value <<< "$station"
        if test -f "$file" && [[ " $times " =~ " $currenttime " ]]; then
            adlength=$adlength_value
            top_of_the_hour_dialog
        fi
    done
}

# Check if off-peak period
check_for_off_peak() {
    currenttime=$(date +%H%M)
    stations=(".lbc:LBC UK:120" ".tr:TalkRadio:170")

    for station in "${stations[@]}"; do
        IFS=':' read -r file station_name timeout_value <<< "$station"
        if test -f "$file" && { [ "$currenttime" -gt "1900" ] || [ "$currenttime" -lt "0600" ]; }; then
            timeout=$timeout_value
        fi
    done
}

# Default adbreak length function
default_adbreak_length() {
    timeout=180
    check_for_off_peak
    while [ "$SECONDS" -gt "$timeout" ]; do
        echo "                  $((timeout - SECONDS))" > ~/.conkytimer
        sleep 2
    done
}

# Main script
check_top_of_the_hour
mute_app /usr/bin/radiotray-ng
mute_app /usr/bin/vlc
qdbus org.kde.plasmashell /org/kde/osdService org.kde.osdService.volumeChanged 0
default_adbreak_length
conkytimer "$seconds"
unmute_app /usr/bin/radiotray-ng
unmute_app /usr/bin/vlc
show_osd_dialog
