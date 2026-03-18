#!/usr/bin/env bash
set -euo pipefail

# Auto-sync local changes to GitHub while this script runs.
# Usage: ./start.sh [seconds]
# Example: ./start.sh 15

INTERVAL="${1:-15}"

if ! [[ "$INTERVAL" =~ ^[0-9]+$ ]] || [ "$INTERVAL" -lt 3 ]; then
    echo "Bruk: ./start.sh [sekunder] (minst 3)"
    exit 1
fi

if ! git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
    echo "Feil: Denne mappen er ikke et git-repository."
    exit 1
fi

CURRENT_BRANCH="$(git rev-parse --abbrev-ref HEAD)"

echo "Starter auto-sync pa branch: $CURRENT_BRANCH"
echo "Intervall: ${INTERVAL}s"
echo "Trykk Ctrl+C for a stoppe."

sync_once() {
    if [ -n "$(git status --porcelain)" ]; then
        git add -A
        COMMIT_MSG="auto: oppdatering $(date '+%Y-%m-%d %H:%M:%S')"

        if git commit -m "$COMMIT_MSG" >/dev/null 2>&1; then
            echo "[$(date '+%H:%M:%S')] Commit laget: $COMMIT_MSG"
            git push origin "$CURRENT_BRANCH"
            echo "[$(date '+%H:%M:%S')] Pushet til origin/$CURRENT_BRANCH"
        else
            echo "[$(date '+%H:%M:%S')] Ingen commit laget (ingen sporbare endringer)."
        fi
    fi
}

while true; do
    sync_once
    sleep "$INTERVAL"
done
