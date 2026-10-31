#!/usr/bin/env bash
# Emits one JSON object describing current system stats, then exits.
# SystemStatsService.qml runs this once per poll tick and computes CPU/disk
# usage from the deltas between consecutive samples.
set -u

json_escape() {
    printf '%s' "$1" | sed 's/\\/\\\\/g; s/"/\\"/g'
}

read_temp() {
    [ -n "$1" ] && [ -r "$1" ] && cat "$1" 2>/dev/null
}

# ---------------------------------------------------------------------------
# One-time discovery (cheap enough to redo every tick)
# ---------------------------------------------------------------------------

cpu_vendor=$(awk -F: '/^vendor_id/{gsub(/ /, "", $2); print $2; exit}' /proc/cpuinfo)
is_amd=0
[ "$cpu_vendor" = "AuthenticAMD" ] && is_amd=1

cpu_hwmon=""
gpu_hwmon=""
ram_hwmon=""

for h in /sys/class/hwmon/hwmon*; do
    [ -r "$h/name" ] || continue
    name=$(cat "$h/name" 2>/dev/null)

    case "$name" in
        k10temp | coretemp | zenpower)
            [ -z "$cpu_hwmon" ] && cpu_hwmon="$h"
            ;;
        amdgpu | radeon | i915 | xe | nouveau)
            [ -z "$gpu_hwmon" ] && gpu_hwmon="$h"
            ;;
        spd5118 | jc42 | ee1004)
            [ -z "$ram_hwmon" ] && ram_hwmon="$h"
            ;;
    esac
done

gpu_busy=""
for c in /sys/class/drm/card*/device/gpu_busy_percent; do
    if [ -r "$c" ]; then
        gpu_busy="$c"
        break
    fi
done

# Physical block devices only, with their optional hwmon temperature sensor.
disks=()
for b in /sys/block/*; do
    disk_name=$(basename "$b")

    case "$disk_name" in
        loop* | zram* | dm-* | sr* | ram*)
            continue
            ;;
    esac

    [ -e "$b/device" ] || continue

    disk_temp_file=""
    for t in "$b"/device/hwmon/hwmon*/temp1_input "$b"/device/hwmon*/temp1_input; do
        if [ -r "$t" ]; then
            disk_temp_file="$t"
            break
        fi
    done

    disks+=("$disk_name|$disk_temp_file")
done

# ---------------------------------------------------------------------------
# Sample
# ---------------------------------------------------------------------------

read -r _ cpu_user cpu_nice cpu_sys cpu_idle cpu_iowait cpu_irq cpu_softirq _ < /proc/stat
cpu_total=$((cpu_user + cpu_nice + cpu_sys + cpu_idle + cpu_iowait + cpu_irq + cpu_softirq))
cpu_idle_total=$((cpu_idle + cpu_iowait))

mem_total=$(awk '/^MemTotal:/{print $2}' /proc/meminfo)
mem_available=$(awk '/^MemAvailable:/{print $2}' /proc/meminfo)

cpu_temp=$(read_temp "${cpu_hwmon}/temp1_input")
gpu_temp=$(read_temp "${gpu_hwmon}/temp1_input")
ram_temp=$(read_temp "${ram_hwmon}/temp1_input")

if [ -n "$gpu_busy" ]; then
    gpu_usage=$(cat "$gpu_busy" 2>/dev/null)
else
    gpu_usage=null
fi

boost=null
if [ "$is_amd" = "1" ] && [ -r /sys/devices/system/cpu/cpufreq/boost ]; then
    boost=$(cat /sys/devices/system/cpu/cpufreq/boost 2>/dev/null)
fi

disk_json=""
for entry in "${disks[@]}"; do
    disk_name="${entry%%|*}"
    disk_temp_file="${entry#*|}"
    stat_file="/sys/block/${disk_name}/stat"

    [ -r "$stat_file" ] || continue

    read -r _r_ios _r_merge r_sectors _r_ticks _w_ios _w_merge w_sectors _w_ticks _ < "$stat_file"

    disk_temp=$(read_temp "$disk_temp_file")
    [ -z "$disk_temp" ] && disk_temp=null

    disk_json="${disk_json}${disk_json:+,}{\"name\":\"$(json_escape "$disk_name")\",\"readSectors\":${r_sectors:-0},\"writeSectors\":${w_sectors:-0},\"temp\":${disk_temp}}"
done

printf '{"cpuTotal":%s,"cpuIdle":%s,"memTotal":%s,"memAvailable":%s,"cpuTemp":%s,"gpuTemp":%s,"ramTemp":%s,"gpuUsage":%s,"amd":%s,"boost":%s,"disks":[%s]}\n' \
    "$cpu_total" \
    "$cpu_idle_total" \
    "$mem_total" \
    "$mem_available" \
    "${cpu_temp:-null}" \
    "${gpu_temp:-null}" \
    "${ram_temp:-null}" \
    "$gpu_usage" \
    "$([ "$is_amd" = "1" ] && echo true || echo false)" \
    "$boost" \
    "$disk_json"
