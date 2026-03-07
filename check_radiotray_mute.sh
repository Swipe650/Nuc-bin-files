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

if [ $? = 0 ]; then
qdbus com.github.radiotray_ng /com/github/radiotray_ng com.github.radiotray_ng.mute
fi
