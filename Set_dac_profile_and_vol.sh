#!/bin/bash
pactl set-card-profile 1 off
pactl set-card-profile 1 output:iec958-stereo
amixer -c 2 set PCM 80%
