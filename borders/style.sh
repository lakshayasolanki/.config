#!/bin/bash
# Square border for Ghostty (0 radius), rounded for every other app.
# Only touches borders when the style actually changes; hides the border
# while the shape flips so the wrong shape is never drawn.
B=/opt/homebrew/bin/borders
STATE=/tmp/borders-style
APP=$(/opt/homebrew/bin/aerospace list-windows --focused --format '%{app-bundle-id}' 2>/dev/null)
[ "$APP" = "com.mitchellh.ghostty" ] && WANT=square || WANT=round
[ "$(cat $STATE 2>/dev/null)" = "$WANT" ] && exit 0
echo "$WANT" > $STATE
$B active_color=0x00000000 style=$WANT
sleep 0.03
$B active_color=0xff3df5a7
