#!/bin/bash

# Run xrandr command to get information about monitor outputs
xrandr_output=$(xrandr)

# Use grep to filter out lines containing information about monitor outputs
monitor_lines=$(echo "$xrandr_output" | grep -E '\b[A-Z]+-[A-Z]+-[0-9]+')

# Loop through each line to extract the monitor output names
while IFS= read -r line; do
    # Extract the monitor output name using awk or any other appropriate method
    monitor_name=$(echo "$line" | awk '{print $1}')
    echo "$monitor_name"
done <<< "$monitor_lines"


