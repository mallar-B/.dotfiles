#!/usr/bin/env bash

mapfile -t sinks < <(
    wpctl status | awk '
        /Sinks:/   { insinks=1; next }
        /Sources:/ { insinks=0 }
        insinks && match($0, /[0-9]+\./) {
            id = substr($0, RSTART, RLENGTH - 1)
            print id
        }
    '
)

if (( ${#sinks[@]} == 0 )); then
    echo "No output devices found."
    exit 1
fi

current=$(
    wpctl status | awk '
        /Sinks:/   { insinks=1; next }
        /Sources:/ { insinks=0 }
        insinks && /\*/ && match($0, /[0-9]+\./) {
            print substr($0, RSTART, RLENGTH - 1)
            exit
        }
    '
)

next="${sinks[0]}"

for i in "${!sinks[@]}"; do
    if [[ "${sinks[$i]}" == "$current" ]]; then
        next="${sinks[$(( (i + 1) % ${#sinks[@]} ))]}"
        break
    fi
done

wpctl set-default "$next"

# Move existing audio streams to the new sink
while read -r stream; do
    wpctl move "$stream" "$next" 2>/dev/null
done < <(
    wpctl status | awk '
        /Streams:/ { instreams=1; next }
        instreams && match($0, /[0-9]+\./) {
            print substr($0, RSTART, RLENGTH - 1)
        }
    '
)

echo "Switched output to:"
wpctl inspect "$next" |
    awk -F'"' '/node.description/ { print $2; exit }'
