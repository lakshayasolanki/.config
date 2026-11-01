#!/usr/bin/env zsh

# Prints the path of a 40px green-tinted PNG of an app's icon, from its bundle id (cached)
# Usage: app_icon.sh <bundle-id> [dark]   (dark = for use on the solid green highlight)

BUNDLE_ID=$1
VARIANT=${2:-light}
DIR="$HOME/.cache/sketchybar-icons"
RAW="$DIR/$BUNDLE_ID.raw.png"
FILE="$DIR/$BUNDLE_ID.$VARIANT.png"
mkdir -p "$DIR"

if [[ ! -f $RAW ]]; then
    APP=$(mdfind "kMDItemCFBundleIdentifier == '$BUNDLE_ID'" | head -1)
    # Not found (e.g. Safari web apps): generic app icon
    [[ -z $APP ]] && APP="/System/Library/CoreServices/CoreTypes.bundle/Contents/Resources/GenericApplicationIcon.icns"
    # Resolve symlinks so the icon has no alias arrow
    APP=${APP:A}

    TMP=$(mktemp "$DIR/.tmp.XXXXXX")
    osascript -l JavaScript - "$APP" "$TMP" <<'JXA' >/dev/null 2>&1
ObjC.import('AppKit');
function run(argv) {
    const icon = $.NSWorkspace.sharedWorkspace.iconForFile(argv[0]);
    const rep = $.NSBitmapImageRep.imageRepWithData(icon.TIFFRepresentation);
    return rep.representationUsingTypeProperties(4, $()).writeToFileAtomically(argv[1], true);
}
JXA
    sips -s format png -z 40 40 "$TMP" --out "$RAW" >/dev/null 2>&1
    rm -f "$TMP"
    [[ -f $RAW ]] || exit 1
fi

# Recolor: keep the icon's shading and transparency, map it onto the bar's greens
if [[ ! -f $FILE ]]; then
    /usr/bin/python3 - "$RAW" "$FILE" "$VARIANT" <<'PY' || exit 1
import sys
from PIL import Image, ImageOps
raw, out, variant = sys.argv[1:4]
im = Image.open(raw).convert("RGBA")
alpha = im.getchannel("A")
gray = ImageOps.autocontrast(im.convert("L"), cutoff=2)
if variant == "dark":   # on the solid green highlight
    lo, hi = (5, 11, 7), (125, 195, 155)
else:                   # on the dark pill
    lo, hi = (30, 66, 46), (170, 215, 186)
tinted = ImageOps.colorize(gray, black=lo, white=hi).convert("RGBA")
tinted.putalpha(alpha)
tinted.save(out)
PY
fi

print -r -- "$FILE"
