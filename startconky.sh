#!/bin/bash
sleep 1
killall -9 conky
conky -c ~/.conky/Gotham/Gotham
conky -c ~/.conky/conkytidal/conkytidal 
conky -c ~/.conky/conkyrtng
