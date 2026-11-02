#!/usr/bin/env zsh

# AeroSpace workspaces: id + the real icons of the apps open in it.
# Per workspace: one text item (id) and up to 4 icon slots, grouped in a bracket.
# plugins/aerospace.sh fills them in.
# Needs aerospace's exec-on-workspace-change to trigger aerospace_workspace_change
#
# Everything goes to sketchybar in ONE call: a call per item made startup take over a second.

SLOTS=4
rm -f "$HOME/.cache/sketchybar-spaces.state"

args=(--add event aerospace_workspace_change)

for ws in $(aerospace list-workspaces --all); do
    args+=(
        --add item space.$ws left
        --set space.$ws
            drawing=off
            icon=$ws
            icon.font="$FONT_FACE:Bold:13.0"
            icon.padding_left=8
            icon.padding_right=5
            label.drawing=off
            background.padding_left=0
            background.padding_right=0
            click_script="aerospace workspace $ws"
    )

    members=(space.$ws)
    for i in {1..$SLOTS}; do
        args+=(
            --add item space.$ws.$i left
            --set space.$ws.$i
                drawing=off
                icon.drawing=off
                label.drawing=off
                background.drawing=on
                background.color=0x00000000
                background.image.scale=0.5
                background.padding_left=0
                background.padding_right=4
                click_script="aerospace workspace $ws"
        )
        members+=(space.$ws.$i)
    done

    # Highlight pill for this workspace (solid when focused)
    args+=(
        --add bracket ws.$ws $members
        --set ws.$ws
            drawing=off
            background.color=0x00000000
            background.height=24
            background.corner_radius=7
            background.padding_left=2
            background.padding_right=2
    )
done

# One pill behind all workspaces
args+=(
    --add bracket workspaces '/space\..*/'
    --set workspaces
        background.color=0xcc0b110d
        background.border_color=0x664f9a6e
        background.border_width=1
        background.height=28
        background.corner_radius=8
        background.padding_right=8

    # One item runs the shared script and updates every pill
    --add item spaces_ctl left
    --set spaces_ctl
        drawing=off
        updates=on
        update_freq=3
        script="$PLUGIN_SHARED_DIR/aerospace.sh"
    --subscribe spaces_ctl aerospace_workspace_change front_app_switched system_woke
)

sketchybar "${args[@]}"
