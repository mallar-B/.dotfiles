#!/bin/bash

xrandr_output=$(xrandr)

monitor_names=()

while IFS= read -r line; do
    # Check if the line contains " connected"
    if [[ $line == *" connected"* ]]; then
        # Split the line by space and get the first element
        monitor_name=$(echo "$line" | awk '{print $1}')
        monitor_names+=("$monitor_name")
    fi
done <<< "$xrandr_output"

echo "${monitor_names[@]}"
