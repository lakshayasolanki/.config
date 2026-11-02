#!/usr/bin/env zsh

# Draws AeroSpace workspaces: id + real app icons of the apps open in each.
# Empty workspaces are hidden unless focused.

SLOTS=4
ICON_CMD="$HOME/.config/sketchybar/plugins/app_icon.sh"

# Skip if a previous run is still going (first run builds the icon cache)
LOCK="$HOME/.cache/sketchybar-spaces.lock"
mkdir -p "${LOCK:h}"
if ! mkdir "$LOCK" 2>/dev/null; then
    # Stale lock (older than a minute)? take it over
    [[ -n $(find "$LOCK" -maxdepth 0 -mmin +1 2>/dev/null) ]] && rmdir "$LOCK" && mkdir "$LOCK" || return
fi
trap 'rmdir "$LOCK" 2>/dev/null' EXIT

FOCUSED=${FOCUSED_WORKSPACE:-$(aerospace list-workspaces --focused)}

typeset -A APPS
while IFS=$'\t' read -r ws bundle; do
    [[ -z $ws || -z $bundle ]] && continue
    [[ " ${APPS[$ws]} " == *" $bundle "* ]] || APPS[$ws]+="${APPS[$ws]:+ }$bundle"
done < <(aerospace list-windows --all --format '%{workspace}%{tab}%{app-bundle-id}')

args=()
for ws in $(aerospace list-workspaces --all); do
    apps=(${=APPS[$ws]})

    if [[ $ws == $FOCUSED ]]; then
        args+=(--set space.$ws drawing=on icon.color=0xff000000 --set ws.$ws drawing=on background.color=0xff3df5a7)
    elif (( ${#apps} > 0 )); then
        args+=(--set space.$ws drawing=on icon.color=0xffd4d4d0 --set ws.$ws drawing=on background.color=0x00000000)
    else
        args+=(--set space.$ws drawing=off --set ws.$ws drawing=off)
    fi

    variant=light
    [[ $ws == $FOCUSED ]] && variant=dark

    for i in {1..$SLOTS}; do
        if [[ -n ${apps[$i]} ]] && icon_file=$("$ICON_CMD" ${apps[$i]} $variant) && [[ -n $icon_file ]]; then
            args+=(--set space.$ws.$i drawing=on background.image="$icon_file")
        else
            args+=(--set space.$ws.$i drawing=off)
        fi
    done
done

# Only talk to sketchybar when something changed (this runs every few seconds)
STATE="$HOME/.cache/sketchybar-spaces.state"
NEW=$(print -r -- "${args[@]}" | md5)
if [[ $NEW != $(cat "$STATE" 2>/dev/null) ]]; then
    sketchybar "${args[@]}" && print -r -- $NEW >"$STATE"
fi

# Workspace pill width changed: re-check whether weather still fits beside the notch
"$HOME/.config/sketchybar/plugins/weather_place.sh" &
