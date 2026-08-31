#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
IMG="$ROOT/assets/img"
WORK="$ROOT/scripts/work"
OUT="$ROOT/assets/video"
mkdir -p "$WORK" "$OUT"

HOLD=5.5
FADE=1.1
OFFSET=$(python3 -c "print(round($HOLD - $FADE, 2))")

# Fill 1920x1080 edge to edge. No letterbox, no zoom.
cover() {
  ffmpeg -y -hide_banner -loglevel error -loop 1 -i "$1" \
    -vf "scale=1920:1080:force_original_aspect_ratio=increase,crop=1920:1080,fps=30,format=yuv420p" \
    -t "$HOLD" -an -c:v libx264 -preset medium -crf 20 "$2"
}

cover      "$IMG/house-front.jpg"           "$WORK/c1.mp4"
cover      "$IMG/house-pole-sign-right.jpg" "$WORK/c2.mp4"
cover      "$IMG/house-sign.jpg"            "$WORK/c3.mp4"

# Each fade starts fade-seconds before the current output ends.
OFF2=$(python3 -c "print(round($OFFSET + $HOLD - $FADE, 2))")
OFF3=$(python3 -c "print(round($OFFSET + $HOLD + $HOLD - 2 * $FADE, 2))")
LOOP=$(python3 -c "print(round($OFFSET + $HOLD + $HOLD - $FADE, 2))")

ffmpeg -y -hide_banner -loglevel error \
  -i "$WORK/c1.mp4" -i "$WORK/c2.mp4" -i "$WORK/c3.mp4" -i "$WORK/c1.mp4" \
  -filter_complex "\
    [0][1]xfade=transition=fade:duration=${FADE}:offset=${OFFSET}[a];\
    [a][2]xfade=transition=fade:duration=${FADE}:offset=${OFF2}[b];\
    [b][3]xfade=transition=fade:duration=${FADE}:offset=${OFF3}[c];\
    [c]trim=duration=${LOOP},setpts=PTS-STARTPTS,format=yuv420p[v]" \
  -map "[v]" -an -c:v libx264 -preset slow -crf 22 -movflags +faststart \
  "$OUT/hero.mp4"

ffmpeg -y -hide_banner -loglevel error -i "$IMG/house-front.jpg" \
  -vf "scale=1920:1080:force_original_aspect_ratio=increase,crop=1920:1080" \
  -q:v 3 "$OUT/hero-poster.jpg"

echo "Wrote $OUT/hero.mp4  (loop ${LOOP}s)"
ls -lh "$OUT/hero.mp4"
