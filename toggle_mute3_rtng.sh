#!/bin/bash

mute () { "$HOME/bin/mute_radiotray-ng" -m /usr/bin/radiotray-ng && rename_xmuted; }
unmute () { "$HOME/bin/mute_radiotray-ng" -u /usr/bin/radiotray-ng && rename_muted; }
mute_vlc () { "$HOME/bin/mute_radiotray-ng" -m /usr/bin/vlc; }
unmute_vlc () { "$HOME/bin/mute_radiotray-ng" -u /usr/bin/vlc; }
# high_vol () { "$HOME/bin/mute_radiotray-ng" -h /usr/bin/radiotray-ng; }
# low_vol () { "$HOME/bin/mute_radiotray-ng" -l /usr/bin/radiotray-ng; }
# peep () { sleep 0.75; }
rename_xmuted () { if [ -f "$HOME/.conky/xmuted.png" ]; then { mv "$HOME/.conky/xmuted.png" "$HOME/.conky/muted.png"; } fi }
rename_muted () { if [ -f "$HOME/.conky/muted.png" ]; then { mv "$HOME/.conky/muted.png" "$HOME/.conky/xmuted.png"; } fi }


# Conky countdown timer
conkytimer()
{
   #trap "rm ~/.conkytimer" INT

   sec=$1
   # millisecondsToseonds=$(( $1/1000 ))

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


check_top_of_the_hour()
{  
# Get current time in minutes
    currenttime=$(date +%M)

# check time for Talkradio
    st=$(test -f .tr && echo "TalkRadio")
    talkradio='TalkRadio'
    case "$st" in 
    "$talkradio" )
    
    if [ "$currenttime" -eq "01" ] || [ "$currenttime" -eq "02" ] || [ "$currenttime" -eq "03" ]  || [ "$currenttime" -eq "04" ]; then
    
   
    
    declare -i adlength=60
         
    top_of_the_hour_dialog
    
#     elif [ "$currenttime" -eq "33" ] || [ "$currenttime" -eq "34" ]  || [ "$currenttime" -eq "35" ] || [ "$currenttime" -eq "36" ]  || [ "$currenttime" -eq "37" ]; then

    elif [ "$currenttime" -ge "29" ] && [ "$currenttime" -le "37" ]; then
    
    declare -i adlength=170
         
    top_of_the_hour_dialog
    
    fi
    esac
    
    
    # check time for lbc
    st=$(test -f .lbc && echo "LBC UK")
    lbc='LBC UK'
    case "$st" in 
    "$lbc" )

    if [ "$currenttime" -gt "00" ] && [ "$currenttime" -lt "07" ]; then
# 
    declare -i adlength=30
         
    top_of_the_hour_dialog
             
    fi
    
    esac
}

check_top_of_the_hour

mute
mute_vlc

qdbus org.kde.plasmashell /org/kde/osdService org.kde.osdService.volumeChanged 0



check_for_off_peak()
{  
   # Get current time in minutes
   currenttime=$(date +%H%M)

   if [ "$currenttime" -gt "1900" ] || [ "$currenttime" -lt "0600" ]; then
   timeout=170
   fi
}



# Function for default adbreak length
default_adbreak_length()
{
   # Sets timeout value for function
   timeout=180 # <--- Set value for adbreak length

   # Run check_for_off_peak()
   check_for_off_peak

   #Wait until $SECONDS (time of running script) is greater than $timeout then execute do loop
   until [ "$SECONDS" -gt $timeout ] 

      do
         display="                  $((timeout - SECONDS))*"
         echo "$display" > ~/.conkytimer
         sleep 2
      done
}


default_adbreak_length



conkytimer "$seconds"

#lbc ;
unmute
unmute_vlc

show_osd_dialog
