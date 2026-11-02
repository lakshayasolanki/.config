#!/usr/bin/env zsh

# Current condition icon + temperature only.
# Paints the last known value instantly, then refreshes from the network.

CACHE="$HOME/.cache/sketchybar-weather"
mkdir -p "${CACHE:h}"

if [[ -f $CACHE ]]; then
    IFS=$'\t' read -r C_ICON C_LABEL <"$CACHE"
    sketchybar --set $NAME icon="$C_ICON" label="$C_LABEL"
fi

LOCATION_JSON=$("$HOME/.config/sketchybar/plugins/location.sh")
LOCATION="$(echo $LOCATION_JSON | jq -r '.city')"
REGION="$(echo $LOCATION_JSON | jq -r '.region')"

LOCATION_ESCAPED="${LOCATION// /+}+${REGION// /+}"
WEATHER_JSON=$(curl -s --max-time 8 "https://wttr.in/$LOCATION_ESCAPED?format=j1")

TEMPERATURE=$(echo $WEATHER_JSON | jq -r '.current_condition[0].temp_C // empty')
CODE=$(echo $WEATHER_JSON | jq -r '.current_condition[0].weatherCode // empty')

if [[ -z $TEMPERATURE ]]; then
    [[ -f $CACHE ]] || sketchybar --set $NAME label="--"
    return
fi

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

LABEL="${TEMPERATURE}°C"
sketchybar --set $NAME icon=$ICON label="$LABEL"
printf '%s\t%s\n' "$ICON" "$LABEL" >"$CACHE"
