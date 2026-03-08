#!/bin/bash

# Get radiotray-ng ID and toggle mute
wpctl set-mute $(wpctl status | awk '/Streams:/ {f=1; next} f && /radiotray-ng/ {print $1; exit}' | tr -d '.') toggle
# wpctl set-mute $(wpctl status | awk '/Streams:/ {f=1; next} f && /vlc/ {print $1; exit}' | tr -d '.') toggle
