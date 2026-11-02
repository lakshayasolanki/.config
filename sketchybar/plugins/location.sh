#!/usr/bin/env zsh

# Prints ipinfo.io JSON for this machine, cached for 30 minutes (one request instead of two,
# and shared by weather.sh and aqi.sh)

CACHE="$HOME/.cache/sketchybar-location.json"
mkdir -p "${CACHE:h}"

if [[ -z $(find "$CACHE" -mmin -30 2>/dev/null) ]]; then
    JSON=$(curl -s --max-time 5 https://ipinfo.io/json)
    # Keep the old cache if the request failed
    [[ -n $JSON && $(print -r -- "$JSON" | jq -r '.loc // empty') != "" ]] && print -r -- "$JSON" >"$CACHE"
fi

cat "$CACHE" 2>/dev/null
