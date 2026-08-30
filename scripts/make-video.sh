#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
IMG="$ROOT/assets/img"
WORK="$ROOT/scripts/work"
OUT="$ROOT/assets/video"
mkdir -p "$WORK" "$OUT"

# Hold stills in 1920x1080. No zoom. Subject sits on the right so
# the hero type on the left does not cover the house or sign.
still_right() {
  ffmpeg -y -hide_banner -loglevel error -loop 1 -i "$1" \
    -vf "scale=-2:1080,pad=1920:1080:ow-iw:0:color=0x3d82c4,fps=30,format=yuv420p" \
    -t 5.5 -an -c:v libx264 -preset medium -crf 20 "$2"
}

# Crop empty sky, then place the sign in the open right of the frame.
still_sign() {
  ffmpeg -y -hide_banner -loglevel error -loop 1 -i "$1" \
    -vf "crop=iw*0.62:ih:0:0,scale=-2:1080,pad=1920:1080:ow-iw-80:0:color=0x3d82c4,fps=30,format=yuv420p" \
    -t 5.5 -an -c:v libx264 -preset medium -crf 20 "$2"
}

still_right "$IMG/house-front.jpg"     "$WORK/c1.mp4"
still_sign  "$IMG/house-pole-sign.jpg" "$WORK/c2.mp4"
still_right "$IMG/house-sign.jpg"      "$WORK/c3.mp4"

ffmpeg -y -hide_banner -loglevel error \
  -i "$WORK/c1.mp4" -i "$WORK/c2.mp4" -i "$WORK/c3.mp4" \
  -filter_complex "\
    [0][1]xfade=transition=fade:duration=1.1:offset=4.4[a];\
    [a][2]xfade=transition=fade:duration=1.1:offset=8.8,format=yuv420p[v]" \
  -map "[v]" -an -c:v libx264 -preset slow -crf 22 -movflags +faststart \
  "$OUT/hero.mp4"

ffmpeg -y -hide_banner -loglevel error -i "$IMG/house-front.jpg" \
  -vf "scale=-2:1080,pad=1920:1080:ow-iw:0:color=0x3d82c4" \
  -q:v 3 "$OUT/hero-poster.jpg"

echo "Wrote $OUT/hero.mp4"
ls -lh "$OUT/hero.mp4"
