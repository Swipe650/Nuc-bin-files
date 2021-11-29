#!/bin/bash

google_home="Living Room mini"
#google_home="Bedroom mini"

get_vol=$("$HOME/bin/cast-linux-amd64" --name "$google_home" status | awk -F 'Volume:' '{print $2}' | cut -c2-5)

vol=$get_vol

mute () { "$HOME/bin/cast-linux-amd64" --name "$google_home" volume 0; }


unmute () { "$HOME/bin/cast-linux-amd64" --name "$google_home" volume $vol ; }

set_default_mute_time()
{
    mute
    
    sleep 250
     
    unmute
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
    
    if [ "$currenttime" -eq "58" ] || [ "$currenttime" -eq "59" ]  || [ "$currenttime" -eq "00" ] || [ "$currenttime" -eq "01" ] || [ "$currenttime" -eq "02" ] || [ "$currenttime" -eq "03" ]  || [ "$currenttime" -eq "04" ]; then
    
    mute
    
    sleep 210
     
    unmute
    
    else
    
    set_default_mute_time
    
    fi
    esac
    
    # check time for lbc
    st=$(test -f .lbc && echo "LBC UK")
    lbc='LBC UK'
    case "$st" in 
    "$lbc" )

    if [ "$currenttime" -gt "00" ] && [ "$currenttime" -lt "07" ]; then
# 
    mute
    
    sleep 30
     
    unmute
    
    else
    
    set_default_mute_time
    
    fi
    
    esac
}

check_top_of_the_hour 
