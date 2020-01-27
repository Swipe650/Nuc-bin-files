#!/bin/sh
LOG=/var/log/trim.log
echo "*** $(date -R) ***" >> $LOG

#fstrim -v /boot >> $LOG
#fstrim -v / >> $LOG
#fstrim -v /home >> $LOG

# trim all supported mounted filesystems from /etc/fstab
sudo fstrim --fstab --verbose >> $LOG
