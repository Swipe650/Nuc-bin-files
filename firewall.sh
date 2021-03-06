#!/bin/bash

sudo ufw reset
sudo ufw default deny incoming
sudo ufw default deny outgoing
sudo ufw allow 1714:1764/udp
sudo ufw allow 1714:1764/tcp
sudo ufw allow 22/tcp
sudo ufw allow 5556/tcp
sudo ufw allow 5558/tcp
sudo ufw allow 8009:8010/tcp
sudo ufw allow 8009:8010/udp
sudo ufw allow out on tun0 from any to any
sudo ufw allow in on tun0 from any to any
sudo ufw enable

if [ -e /home/swipe/.conky/fwoff.png ] 
then
mv /home/swipe/.conky/fwoff.png /home/swipe/.conky/fwon.png
fi
