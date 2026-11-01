#!/usr/bin/env zsh

# Current condition icon + temperature only

IP=$(curl -s https://ipinfo.io/ip)
LOCATION_JSON=$(curl -s https://ipinfo.io/$IP/json)

LOCATION="$(echo $LOCATION_JSON | jq -r '.city')"
REGION="$(echo $LOCATION_JSON | jq -r '.region')"

LOCATION_ESCAPED="${LOCATION// /+}+${REGION// /+}"
WEATHER_JSON=$(curl -s "https://wttr.in/$LOCATION_ESCAPED?format=j1")

if [[ -z $WEATHER_JSON ]]; then
    sketchybar --set $NAME label="--"
    return
fi

TEMPERATURE=$(echo $WEATHER_JSON | jq -r '.current_condition[0].temp_C')
CODE=$(echo $WEATHER_JSON | jq -r '.current_condition[0].weatherCode')

HOUR=$(date +%-H)
(( HOUR < 6 || HOUR >= 19 )) && NIGHT=1

case $CODE in
113)
    ICON=$'\U000F0599'; [[ -n $NIGHT ]] && ICON=$'\U000F0594' ;;
116)
    ICON=$'\U000F0595'; [[ -n $NIGHT ]] && ICON=$'\U000F0F31' ;;
119 | 122)
    ICON=$'\U000F0590' ;;
143 | 248 | 260)
    ICON=$'\U000F0591' ;;
176 | 263 | 266 | 293 | 296 | 299 | 302 | 353)
    ICON=$'\U000F0597' ;;
305 | 308 | 356 | 359)
    ICON=$'\U000F0596' ;;
179 | 182 | 185 | 227 | 230 | 281 | 284 | 311 | 314 | 317 | 320 | 323 | 326 | 329 | 332 | 335 | 338 | 350 | 362 | 365 | 368 | 371 | 374 | 377)
    ICON=$'\U000F0598' ;;
200 | 386 | 389 | 392 | 395)
    ICON=$'\U000F067E' ;;
*)
    ICON=$'\U000F0590' ;;
esac

sketchybar --set $NAME icon=$ICON label="${TEMPERATURE}°C"
