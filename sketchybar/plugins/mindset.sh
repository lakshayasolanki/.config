#!/usr/bin/env zsh

MINDSET_FILE="$HOME/.config/sketchybar/mindset.txt"
STATE_FILE="${TMPDIR:-/tmp}/sketchybar_mindset_offset"
VISIBLE_LENGTH=24

update_mindset() {
    [[ -f "$MINDSET_FILE" ]] || printf "locked in\n" > "$MINDSET_FILE"

    MINDSET="$(tr '\n' ' ' < "$MINDSET_FILE" | sed 's/[[:space:]]\{1,\}/ /g; s/^ //; s/ $//')"

    if [[ -z "$MINDSET" ]]; then
        sketchybar --set "$NAME" label.drawing=off
        exit 0
    fi

    if (( ${#MINDSET} <= VISIBLE_LENGTH )); then
        printf "0" > "$STATE_FILE"
        sketchybar --set "$NAME" label="$MINDSET" label.drawing=on
        exit 0
    fi

    OFFSET=0
    if [[ -f "$STATE_FILE" ]]; then
        OFFSET="$(< "$STATE_FILE")"
        [[ "$OFFSET" == <-> ]] || OFFSET=0
    fi

    SCROLL_TEXT="${MINDSET}  "
    SCROLL_LENGTH=${#SCROLL_TEXT}
    OFFSET=$((OFFSET % SCROLL_LENGTH))
    WINDOW="${SCROLL_TEXT}${SCROLL_TEXT}"
    LABEL="${WINDOW:$OFFSET:$VISIBLE_LENGTH}"

    printf "%s" "$(((OFFSET + 1) % SCROLL_LENGTH))" > "$STATE_FILE"
    sketchybar --set "$NAME" label="$LABEL" label.drawing=on
}

case "$SENDER" in
"mouse.clicked")
    [[ -f "$MINDSET_FILE" ]] || printf "locked in\n" > "$MINDSET_FILE"
    CURRENT_MINDSET="$(tr '\n' ' ' < "$MINDSET_FILE" | sed 's/[[:space:]]\{1,\}/ /g; s/^ //; s/ $//')"
    NEW_MINDSET="$(osascript - "$CURRENT_MINDSET" <<'APPLESCRIPT' 2>/dev/null
on run argv
    text returned of (display dialog "Current mindset" default answer (item 1 of argv) buttons {"Cancel", "Save"} default button "Save")
end run
APPLESCRIPT
)"

    if [[ -n "$NEW_MINDSET" ]]; then
        printf "%s\n" "$NEW_MINDSET" > "$MINDSET_FILE"
        printf "0" > "$STATE_FILE"
        update_mindset
    fi

    exit 0
    ;;
esac

update_mindset
