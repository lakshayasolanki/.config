#!/usr/bin/env zsh

# Battery glyph (10 levels) + percentage; bolt variant while charging

PERCENTAGE=$(pmset -g batt | grep -Eo "\d+%" | cut -d% -f1)
[[ -z $PERCENTAGE ]] && exit 0
pmset -g batt | grep -q 'AC Power' && CHARGING=1

LEVELS=(     $'\U000F007A' $'\U000F007B' $'\U000F007C' $'\U000F007D' $'\U000F007E' $'\U000F007F' $'\U000F0080' $'\U000F0081' $'\U000F0082' $'\U000F0079')
CHARGE_LEVELS=($'\U000F089C' $'\U000F0086' $'\U000F0087' $'\U000F0088' $'\U000F089D' $'\U000F0089' $'\U000F089E' $'\U000F008A' $'\U000F008B' $'\U000F0085')

# 1-10% -> 1, 11-20% -> 2 ... 91-100% -> 10 (zsh arrays are 1-indexed)
IDX=$(( (PERCENTAGE + 9) / 10 ))
(( IDX < 1 )) && IDX=1
(( IDX > 10 )) && IDX=10

if [[ -n $CHARGING ]]; then
    ICON=${CHARGE_LEVELS[$IDX]}
    COLOR=0xffb8a46a
elif (( PERCENTAGE <= 15 )); then
    ICON=${LEVELS[$IDX]}
    COLOR=0xffd45a5a
elif (( PERCENTAGE <= 30 )); then
    ICON=${LEVELS[$IDX]}
    COLOR=0xffd6c486
else
    ICON=${LEVELS[$IDX]}
    COLOR=0xff2fbf84
fi

sketchybar --set $NAME icon=$ICON icon.color=$COLOR label="${PERCENTAGE}%" label.color=0xffd4d4d0
