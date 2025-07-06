#!/bin/bash

REPO_DIR="$HOME/.dotfiles"
LAST_RUN_FILE="$HOME/.config/.last_auto_commit"
NOW=$(date +%s)
DAYS=7
SECS_IN_DAY=$((60 * 60 * 24))
THRESHOLD=$((DAYS * SECS_IN_DAY))

# Check last run
if [ -f "$LAST_RUN_FILE" ]; then
    LAST_RUN=$(cat "$LAST_RUN_FILE")
    AGE=$((NOW - LAST_RUN))
    if [ "$AGE" -lt "$THRESHOLD" ]; then
        echo "Less than 7 days since last run. Skipping."
        exit 0
    fi
fi

cd "$REPO_DIR" || exit 1

git add .

if ! git diff-index --quiet HEAD --; then
    git commit -m "Auto commit on $(date '+%Y-%m-%d %H:%M:%S')"
    git push origin "$(git rev-parse --abbrev-ref HEAD)"
    echo "$NOW" > "$LAST_RUN_FILE"
else
    echo "[$(date)] No changes to commit."
fi

