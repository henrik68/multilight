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
cp -v build/*/app/*.click "$SRC/out/" 2>/dev/null || cp -v $(find build -name '*.click') "$SRC/out/"
echo "Done - .click is in: $SRC/out/"
