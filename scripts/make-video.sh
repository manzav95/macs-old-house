#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
IMG="$ROOT/assets/img"
WORK="$ROOT/scripts/work"
OUT="$ROOT/assets/video"
mkdir -p "$WORK" "$OUT"

scale() {
  ffmpeg -y -hide_banner -loglevel error -i "$1" \
    -vf "scale=1920:1080:force_original_aspect_ratio=increase,crop=1920:1080" \
    -q:v 2 "$2"
}

scale "$IMG/house-sign.jpg" "$WORK/f1.jpg"
scale "$IMG/house-front.jpg" "$WORK/f2.jpg"
scale "$IMG/house-sign.jpg" "$WORK/f3.jpg"

zoom_in() {
  ffmpeg -y -hide_banner -loglevel error -loop 1 -i "$1" \
    -vf "zoompan=z='min(1.06+0.00045*on,1.14)':x='iw/2-(iw/zoom/2)':y='ih/2-(ih/zoom/2)':d=150:s=1920x1080:fps=30,format=yuv420p" \
    -t 5 -an -c:v libx264 -preset medium -crf 20 "$2"
}

zoom_out() {
  ffmpeg -y -hide_banner -loglevel error -loop 1 -i "$1" \
    -vf "zoompan=z='1.14-0.00045*on':x='iw/2-(iw/zoom/2)':y='ih/2-(ih/zoom/2)':d=150:s=1920x1080:fps=30,format=yuv420p" \
    -t 5 -an -c:v libx264 -preset medium -crf 20 "$2"
}

zoom_in  "$WORK/f1.jpg" "$WORK/c1.mp4"
zoom_in  "$WORK/f2.jpg" "$WORK/c2.mp4"
zoom_out "$WORK/f3.jpg" "$WORK/c3.mp4"

ffmpeg -y -hide_banner -loglevel error \
  -i "$WORK/c1.mp4" -i "$WORK/c2.mp4" -i "$WORK/c3.mp4" \
  -filter_complex "\
    [0][1]xfade=transition=fade:duration=1:offset=4[a];\
    [a][2]xfade=transition=fade:duration=1:offset=8,format=yuv420p[v]" \
  -map "[v]" -an -c:v libx264 -preset slow -crf 22 -movflags +faststart \
  "$OUT/hero.mp4"

cp "$WORK/f1.jpg" "$OUT/hero-poster.jpg"
echo "Wrote $OUT/hero.mp4"
ls -lh "$OUT/hero.mp4"
