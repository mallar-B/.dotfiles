#!/usr/bin/env bash

sinks=($(pactl list sinks short | awk '{print $2}'))

current_sink=$(pactl info | grep 'Default Sink' | awk '{print $3}')

current_index=-1
for i in "${!sinks[@]}"; do
  if [[ "${sinks[$i]}" == "$current_sink" ]]; then
    current_index=$i
    break
  fi
done

if [ "$current_index" -eq -1 ]; then
  echo "Current sink not found."
  exit 1
fi

next_index=$(((current_index + 1) % ${#sinks[@]}))

pactl set-default-sink "${sinks[$next_index]}"

echo "Switched to sink: ${sinks[$next_index]}"
