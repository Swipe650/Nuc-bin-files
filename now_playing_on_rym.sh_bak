#!/bin/bash

# Get the current artist using playerctl
artist=$(playerctl metadata artist)

# Check if the artist is available
if [ -z "$artist" ]; then
    echo "No artist is currently playing."
    exit 1
fi

# Replace spaces with '+' for URL encoding
artist_encoded=$(echo "$artist" | sed 's/ /+/g')

# Open the artist page on RateYourMusic
xdg-open "https://rateyourmusic.com/search?searchtype=a&searchterm=$artist_encoded"

# Output the artist name for reference
echo "Now playing: $artist"
