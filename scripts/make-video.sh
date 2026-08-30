#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
IMG="$ROOT/assets/img"
WORK="$ROOT/scripts/work"
OUT="$ROOT/assets/video"
mkdir -p "$WORK" "$OUT"

# Fill 1920x1080 edge to edge. No letterbox, no zoom.
cover() {
  ffmpeg -y -hide_banner -loglevel error -loop 1 -i "$1" \
    -vf "scale=1920:1080:force_original_aspect_ratio=increase,crop=1920:1080,fps=30,format=yuv420p" \
    -t 5.5 -an -c:v libx264 -preset medium -crf 20 "$2"
}

# Keep the pole sign on the left instead of centering it away.
cover_left() {
  ffmpeg -y -hide_banner -loglevel error -loop 1 -i "$1" \
    -vf "scale=1920:1080:force_original_aspect_ratio=increase,crop=1920:1080:0:(ih-oh)/2,fps=30,format=yuv420p" \
    -t 5.5 -an -c:v libx264 -preset medium -crf 20 "$2"
}

cover      "$IMG/house-front.jpg"     "$WORK/c1.mp4"
cover_left "$IMG/house-pole-sign.jpg" "$WORK/c2.mp4"
cover      "$IMG/house-sign.jpg"      "$WORK/c3.mp4"

ffmpeg -y -hide_banner -loglevel error \
  -i "$WORK/c1.mp4" -i "$WORK/c2.mp4" -i "$WORK/c3.mp4" \
  -filter_complex "\
    [0][1]xfade=transition=fade:duration=1.1:offset=4.4[a];\
    [a][2]xfade=transition=fade:duration=1.1:offset=8.8,format=yuv420p[v]" \
  -map "[v]" -an -c:v libx264 -preset slow -crf 22 -movflags +faststart \
  "$OUT/hero.mp4"

ffmpeg -y -hide_banner -loglevel error -i "$IMG/house-front.jpg" \
  -vf "scale=1920:1080:force_original_aspect_ratio=increase,crop=1920:1080" \
  -q:v 3 "$OUT/hero-poster.jpg"

echo "Wrote $OUT/hero.mp4"
ls -lh "$OUT/hero.mp4"
