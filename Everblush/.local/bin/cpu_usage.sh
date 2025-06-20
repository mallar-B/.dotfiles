#!/bin/bash

# Function to read CPU stats
read_cpu_stats() {
    grep '^cpu' /proc/stat > /tmp/cpu_stat
}

# Function to parse stats into arrays
parse_stats() {
    local file=$1
    local -n idle_arr=$2
    local -n total_arr=$3

    while read -r line; do
        fields=($line)
        cpu_id=${fields[0]}
        user=${fields[1]}
        nice=${fields[2]}
        system=${fields[3]}
        idle=${fields[4]}
        iowait=${fields[5]}
        irq=${fields[6]}
        softirq=${fields[7]}
        steal=${fields[8]}
        # guest=${fields[9]}  # not used in calc

        idle_time=$((idle + iowait))
        non_idle=$((user + nice + system + irq + softirq + steal))
        total_time=$((idle_time + non_idle))

        idle_arr["$cpu_id"]=$idle_time
        total_arr["$cpu_id"]=$total_time
    done < "$file"
}

# Take first snapshot
declare -A prev_idle prev_total
read_cpu_stats
parse_stats /tmp/cpu_stat prev_idle prev_total

sleep 1

# Take second snapshot
declare -A curr_idle curr_total
read_cpu_stats
parse_stats /tmp/cpu_stat curr_idle curr_total

# Print CPU usage
for cpu in "${!curr_total[@]}"; do
    total_diff=$((curr_total[$cpu] - prev_total[$cpu]))
    idle_diff=$((curr_idle[$cpu] - prev_idle[$cpu]))

    if (( total_diff == 0 )); then
        usage=0
    else
        usage=$(( (100 * (total_diff - idle_diff)) / total_diff ))
    fi

    echo "$cpu: $usage%;"
done
