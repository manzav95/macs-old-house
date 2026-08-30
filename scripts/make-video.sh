#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
IMG="$ROOT/assets/img"
WORK="$ROOT/scripts/work"
OUT="$ROOT/assets/video"
mkdir -p "$WORK" "$OUT"

# Still 1080p holds only — no zoompan (it jitters on still photos).
still() {
  ffmpeg -y -hide_banner -loglevel error -loop 1 -i "$1" \
    -vf "scale=1920:1080:force_original_aspect_ratio=increase,crop=1920:1080,fps=30,format=yuv420p" \
    -t 5 -an -c:v libx264 -preset medium -crf 20 "$2"
}

still "$IMG/house-sign.jpg"  "$WORK/c1.mp4"
still "$IMG/house-front.jpg" "$WORK/c2.mp4"
still "$IMG/house-sign.jpg"  "$WORK/c3.mp4"

ffmpeg -y -hide_banner -loglevel error \
  -i "$WORK/c1.mp4" -i "$WORK/c2.mp4" -i "$WORK/c3.mp4" \
  -filter_complex "\
    [0][1]xfade=transition=fade:duration=1.2:offset=3.8[a];\
    [a][2]xfade=transition=fade:duration=1.2:offset=7.6,format=yuv420p[v]" \
  -map "[v]" -an -c:v libx264 -preset slow -crf 22 -movflags +faststart \
  "$OUT/hero.mp4"

ffmpeg -y -hide_banner -loglevel error -i "$IMG/house-sign.jpg" \
  -vf "scale=1920:1080:force_original_aspect_ratio=increase,crop=1920:1080" \
  -q:v 3 "$OUT/hero-poster.jpg"

echo "Wrote $OUT/hero.mp4"
ls -lh "$OUT/hero.mp4"
