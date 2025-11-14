#!/bin/bash

# sleep 2

# Target command string
TARGET="/usr/bin/conky -c .conky/Gotham/Gotham"

# Find the PID(s) of the matching process
PIDS=$(pgrep -f "$TARGET")

# Check if any PIDs were found
if [[ -n "$PIDS" ]]; then
echo "Killing process(es): $PIDS"
kill $PIDS
else
echo "No matching conky process found."
fi

sleep 3

conky -c ~/.conky/Gotham/Gotham

exit
