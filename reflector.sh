#!/bin/bash
sudo reflector --verbose --country 'United Kingdom' -l 200 -p http --sort rate --save /etc/pacman.d/mirrorlist
