#!/usr/bin/env zsh

# Weather pill sits right of the notch. While Spotify is showing it moves to the
# left of the notch, and is hidden if the workspaces pill leaves no room there.
# Only changes anything when the state actually changes, so it never flickers.

NOTCH_WIDTH=188
GAP=10
CACHE="$HOME/.cache/sketchybar-weather-width"
mkdir -p "${CACHE:h}"

SPOTIFY=$(sketchybar --query spotify | jq -r '.geometry.drawing')
read POSITION DRAWING <<<"$(sketchybar --query weather | jq -r '[.geometry.position, .geometry.drawing] | @tsv')"

if [[ $SPOTIFY != on ]]; then
    if [[ $POSITION != e || $DRAWING != on ]]; then
        sketchybar --set weather position=e drawing=on --set aqi position=e drawing=on
    fi
    return
fi

# Remember the pill's real width while it is visible; reuse it while hidden
if [[ $DRAWING == on ]]; then
    sketchybar --query weather_bar | jq -r '.bounding_rects["display-1"].size[0]' >"$CACHE"
fi
WEATHER_W=$(cat "$CACHE" 2>/dev/null || echo 110)

SCREEN_W=$(sketchybar --query displays | jq -r '.[0].frame.w')
NOTCH_LEFT=$(( SCREEN_W / 2 - NOTCH_WIDTH / 2 ))
SPACES_RIGHT=$(sketchybar --query workspaces | jq -r '.bounding_rects["display-1"] | .origin[0] + .size[0]')

if (( SPACES_RIGHT + GAP + WEATHER_W > NOTCH_LEFT )); then
    [[ $DRAWING == off ]] || sketchybar --set weather drawing=off --set aqi drawing=off
else
    if [[ $POSITION != q || $DRAWING != on ]]; then
        sketchybar --set weather position=q drawing=on --set aqi position=q drawing=on
    fi
fi
