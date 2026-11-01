#!/usr/bin/env zsh

# US AQI from Open-Meteo (no API key), located via the same IP lookup as weather.sh
LOC=$(curl -s https://ipinfo.io/loc)
LAT=${LOC%,*}
LON=${LOC#*,}

AQI=$(curl -s "https://air-quality-api.open-meteo.com/v1/air-quality?latitude=$LAT&longitude=$LON&current=us_aqi" | jq -r '.current.us_aqi // empty')

if [[ -z $AQI ]]; then
    sketchybar --set $NAME icon=$'\uf059' icon.color=0xffd4d4d0
    return
fi

AQI=${AQI%.*}

if   (( AQI <= 50 ));  then COLOR=0xff2fbf84; ICON=$'\uf118'   # Good
elif (( AQI <= 100 )); then COLOR=0xffb8a46a; ICON=$'\uf11a'   # Moderate
elif (( AQI <= 150 )); then COLOR=0xffd6c486; ICON=$'\uf119'   # Unhealthy for sensitive groups
else                        COLOR=0xffd45a5a; ICON=$'\uf071'   # Unhealthy and worse
fi

sketchybar --set $NAME icon=$ICON icon.color=$COLOR label=$AQI label.drawing=on
