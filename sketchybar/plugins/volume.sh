#!/usr/bin/env zsh

# Click toggles mute
if [[ $SENDER == mouse.clicked ]]; then
    osascript -e 'set volume output muted (not (output muted of (get volume settings)))'
fi

MUTED=$(osascript -e 'output muted of (get volume settings)')
VOLUME=${INFO:-$(osascript -e 'output volume of (get volume settings)')}
[[ $SENDER == mouse.clicked ]] && VOLUME=$(osascript -e 'output volume of (get volume settings)')

if [[ $MUTED == true ]]; then
    ICON=$'\U000F075F'
    COLOR=0xff4a4d4a
    LABEL_COLOR=0xff4a4d4a
elif (( VOLUME == 0 )); then
    ICON=$'\U000F0581'
    COLOR=0xff4a4d4a
    LABEL_COLOR=0xff4a4d4a
elif (( VOLUME <= 33 )); then
    ICON=$'\U000F057F'
    COLOR=0xff2fbf84
    LABEL_COLOR=0xffd4d4d0
elif (( VOLUME <= 66 )); then
    ICON=$'\U000F0580'
    COLOR=0xff2fbf84
    LABEL_COLOR=0xffd4d4d0
else
    ICON=$'\U000F057E'
    COLOR=0xff2fbf84
    LABEL_COLOR=0xffd4d4d0
fi

sketchybar --set $NAME icon=$ICON icon.color=$COLOR label="${VOLUME}%" label.color=$LABEL_COLOR
