#!/bin/bash
# Run xrandr command to get information about monitor outputs

xrandr_output=$(xrandr)

while IFS= read -r line; do
    # Check if the line contains " connected"
    if [[ $line == *" connected"* ]]; then
        # Split the line by space and get the first element
        monitor_name=$(echo "$line" | awk '{print $1}')
    fi
done <<< "$xrandr_output"
echo "$monitor_name"

