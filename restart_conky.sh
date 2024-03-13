#!/bin/bash
killall -9 conky
sleep 3
conky -c $HOME/.conky/Gotham/Gotham
conky -c $HOME/.conky/conkyspotify/conkyspotifylow
