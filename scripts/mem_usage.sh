#!/bin/bash

read total < <(awk '/^MemTotal:/ {print $2}' /proc/meminfo)
read available < <(awk '/^MemAvailable:/ {print $2}' /proc/meminfo)

used=$((total - available))
used_percent=$(( used * 100 / total ))


# Total memory, Used memory, Used Percent
printf "$((total / 1024)) "
printf "$((used / 1024)) "
printf "${used_percent}"

