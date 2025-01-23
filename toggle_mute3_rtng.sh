#!/bin/bash

mute () { "$HOME/bin/mute_radiotray-ng" -m /usr/bin/radiotray-ng && rename_xmuted; }
unmute () { "$HOME/bin/mute_radiotray-ng" -u /usr/bin/radiotray-ng && rename_muted; }
mute_vlc () { "$HOME/bin/mute_radiotray-ng" -m /usr/bin/vlc; }
unmute_vlc () { "$HOME/bin/mute_radiotray-ng" -u /usr/bin/vlc; }
rename_xmuted () { if [ -f "$HOME/.conky/xmuted.png" ]; then { mv "$HOME/.conky/xmuted.png" "$HOME/.conky/muted.png"; } fi }
rename_muted () { if [ -f "$HOME/.conky/muted.png" ]; then { mv "$HOME/.conky/muted.png" "$HOME/.conky/xmuted.png"; } fi }

# Conky countdown timer
conkytimer()
{
   sec=$1
  
   for (( i = 0; i < sec; i++ )); do
         # write remaining sec to file
         timer=$((sec-i))
         display="                  ${timer}"
         echo "$display" > ~/.conkytimer
         # wait 1sec
         sleep 1
   done

   if [[ -f ~/.conkytimer ]]; then rm ~/.conkytimer & touch ~/.conkytimer
   fi
}

# Get current volume level and show OSD dialog
show_osd_dialog()
{
   vollevel=$(amixer -D pulse get Master | awk -F 'Left:|[][]' 'BEGIN {RS=""}{ print $3 }')

   # Show dialog and remove "%" character from $vollevel
   qdbus org.kde.plasmashell /org/kde/osdService org.kde.osdService.volumeChanged "${vollevel::-1}"
}

# top of the hour dialog
top_of_the_hour_dialog()
      {
        mute

        qdbus org.kde.plasmashell /org/kde/osdService org.kde.osdService.volumeChanged 0
        
        conkytimer "$adlength"
          
        unmute

        show_osd_dialog

        exit
      }

check_top_of_the_hour() {
    # Get current time in minutes
    currenttime=$(date +%M)

    # Define station-time mappings and corresponding adlength values
    stations=(
        ".tr:TalkRadio:01 02 03 04:50"
        ".tr:TalkRadio:29 30 31 32 33 34 35 36 37:170"
        ".lbc:LBC UK:00 01 02 03 04 05 06:30"
    )

    # Loop through stations and check time for each IFS=Station Information Array
    for station in "${stations[@]}"; do
        IFS=':' read -r file station_name times adlength_value <<< "$station"
        
        # Check if the station file exists
        if test -f "$file"; then
            # Check if currenttime matches any of the defined times for this station
            if [[ " $times " =~ " $currenttime " ]]; then
                declare -i adlength=$adlength_value
                top_of_the_hour_dialog
            fi
        fi
    done
}


check_top_of_the_hour

mute
mute_vlc

qdbus org.kde.plasmashell /org/kde/osdService org.kde.osdService.volumeChanged 0


check_for_off_peak() 
{
    # Get current time in minutes
    currenttime=$(date +%H%M)
   
    # Define station-time pairs
    stations=(".lbc:LBC UK:120" ".tr:TalkRadio:170")

    # Loop through stations and check time for each
    for station in "${stations[@]}"; do
        IFS=':' read -r file station_name timeout_value <<< "$station"
        
        if test -f "$file"; then
            if [ "$currenttime" -gt "1900" ] || [ "$currenttime" -lt "0600" ]; then
                timeout=$timeout_value
            fi
        fi
    done
}


# Function for default adbreak length
default_adbreak_length() 
{
   # Sets timeout value for function
   timeout=180  # Set value for adbreak length

   # Run check_for_off_peak()
   check_for_off_peak

   # Wait until $SECONDS is greater than $timeout then execute the loop
   while [ "$SECONDS" -le "$timeout" ]; do
      # Display remaining time
      echo "                  $((timeout - SECONDS))" > ~/.conkytimer
      sleep 2
   done
}

default_adbreak_length

conkytimer "$seconds"

unmute
unmute_vlc

show_osd_dialog
