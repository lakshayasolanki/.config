#!/bin/bash
# Hide the border, run the aerospace command, then show the border again.
B=/opt/homebrew/bin/borders
$B active_color=0x00000000
sleep 0.03
/opt/homebrew/bin/aerospace "$@"
sleep 0.12
$B active_color=0xff3df5a7
