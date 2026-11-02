#!/usr/bin/env zsh

# US AQI from Open-Meteo (no API key), located via the shared cached IP lookup.
# Paints the last known value instantly, then refreshes from the network.

CACHE="$HOME/.cache/sketchybar-aqi"
mkdir -p "${CACHE:h}"

if [[ -f $CACHE ]]; then
    IFS=$'\t' read -r C_ICON C_COLOR C_LABEL <"$CACHE"
    sketchybar --set $NAME icon="$C_ICON" icon.color=$C_COLOR label="$C_LABEL" label.drawing=on
fi

LOC=$("$HOME/.config/sketchybar/plugins/location.sh" | jq -r '.loc // empty')
LAT=${LOC%,*}
LON=${LOC#*,}

AQI=$(curl -s --max-time 8 "https://air-quality-api.open-meteo.com/v1/air-quality?latitude=$LAT&longitude=$LON&current=us_aqi" | jq -r '.current.us_aqi // empty')

if [[ -z $AQI ]]; then
    [[ -f $CACHE ]] || sketchybar --set $NAME icon=$'' icon.color=0xff8fbf9f
    return
fi

AQI=${AQI%.*}

if   (( AQI <= 50 ));  then COLOR=0xff6fae88; ICON=$''   # Good
elif (( AQI <= 100 )); then COLOR=0xffa3b36b; ICON=$''   # Moderate
elif (( AQI <= 150 )); then COLOR=0xffc9a15a; ICON=$''   # Unhealthy for sensitive groups
else                        COLOR=0xffc2674f; ICON=$''   # Unhealthy and worse
fi

sketchybar --set $NAME icon=$ICON icon.color=$COLOR label=$AQI label.drawing=on
printf '%s\t%s\t%s\n' "$ICON" "$COLOR" "$AQI" >"$CACHE"
