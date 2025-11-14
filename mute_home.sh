#!/bin/bash

google_home="Kitchen home"
#google_home="Bedroom mini"

# Get the volume status
vol=$(/home/swipe/bin/cast-linux-amd64 --name "$google_home" status | awk -F 'Volume:' '{print $2}' | awk '/muted/ { print "true"; exit }')

# Check if it's muted (vol will be "true" if muted, empty if not)
if [ "$vol" == "true" ]; then
    # Unmute the device
    /home/swipe/bin/cast-linux-amd64 --name "$google_home" unmute
elif [ -z "$vol" ]; then
    # Mute the device if it's not already muted
    /home/swipe/bin/cast-linux-amd64 --name "$google_home" mute
fi
