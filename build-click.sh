#!/bin/bash
# Builds the OpenStore package (.click) with clickable (podman).
# The project path has spaces, which build tools dislike, so it is copied to ~/ut-apps first.
# First time: pipx install clickable-ut   (then open a new terminal)
set -e
SRC="$(dirname "$(readlink -f "$0")")"
DST=~/ut-apps/multilight-click
mkdir -p "$DST"
rsync -a --delete --exclude build "$SRC"/ "$DST"/
cd "$DST"
bash update-translations.sh
clickable build 2>&1 | tee build.log
mkdir -p "$SRC/out"
VER=$(python3 -c 'import json;print(json.load(open("manifest.json"))["version"])')
cp -v $(find build -name "multilight.henrik68_${VER}_*.click") "$SRC/out/"
echo "Done - .click is in: $SRC/out/"
