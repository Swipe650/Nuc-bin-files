#!/bin/bash

check_radiotray_mute() {
  local json_output
  json_output=$(qdbus com.github.radiotray_ng /com/github/radiotray_ng com.github.radiotray_ng.get_player_state)

  if echo "$json_output" | jq -e '.mute == false' > /dev/null; then
    echo "RadioTray-NG is NOT muted"
    return 0
  else
    echo "RadioTray-NG is muted or mute state not found"
    return 1
  fi
}

check_radiotray_mute

if [ $? = 1 ]; then
wpctl set-mute $(wpctl status | awk '/Streams:/ {f=1; next} f && /radiotray-ng/ {print $1; exit}' | tr -d '.') toggle
fi
