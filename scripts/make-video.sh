#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
IMG="$ROOT/scripts/masters"
WORK="$ROOT/scripts/work"
OUT="$ROOT/assets/video"
mkdir -p "$WORK" "$OUT"

scale() {
  local src="$1"
  local dest="$2"
  ffmpeg -y -hide_banner -loglevel error -i "$src" \
    -vf "scale=1920:1080:force_original_aspect_ratio=increase,crop=1920:1080" \
    -q:v 2 "$dest"
}

scale "$IMG/hero-01.jpg" "$WORK/f1.jpg"
scale "$IMG/hero-02.jpg" "$WORK/f2.jpg"
scale "$IMG/hero-03.jpg" "$WORK/f3.jpg"
scale "$IMG/hero-04.jpg" "$WORK/f4.jpg"
scale "$IMG/hero-05.jpg" "$WORK/f5.jpg"

# Slow Ken Burns clips at 30fps, 5 seconds each.
zoom_in() {
  ffmpeg -y -hide_banner -loglevel error -loop 1 -i "$1" \
    -vf "zoompan=z='min(1.08+0.00055*on,1.16)':x='iw/2-(iw/zoom/2)':y='ih/2-(ih/zoom/2)':d=150:s=1920x1080:fps=30,format=yuv420p" \
    -t 5 -an -c:v libx264 -preset medium -crf 18 "$2"
}

zoom_out() {
  ffmpeg -y -hide_banner -loglevel error -loop 1 -i "$1" \
    -vf "zoompan=z='1.16-0.00055*on':x='iw/2-(iw/zoom/2)':y='ih/2-(ih/zoom/2)':d=150:s=1920x1080:fps=30,format=yuv420p" \
    -t 5 -an -c:v libx264 -preset medium -crf 18 "$2"
}

zoom_in  "$WORK/f1.jpg" "$WORK/c1.mp4"
zoom_in  "$WORK/f2.jpg" "$WORK/c2.mp4"
zoom_in  "$WORK/f3.jpg" "$WORK/c3.mp4"
zoom_in  "$WORK/f4.jpg" "$WORK/c4.mp4"
zoom_in  "$WORK/f5.jpg" "$WORK/c5.mp4"
zoom_out "$WORK/f1.jpg" "$WORK/c6.mp4"

# Crossfade chain. Each clip is 5s; fade 1s; offset = 4, 8, 12, 16, 20
ffmpeg -y -hide_banner -loglevel error \
  -i "$WORK/c1.mp4" -i "$WORK/c2.mp4" -i "$WORK/c3.mp4" \
  -i "$WORK/c4.mp4" -i "$WORK/c5.mp4" -i "$WORK/c6.mp4" \
  -filter_complex "\
    [0][1]xfade=transition=fade:duration=1:offset=4[a];\
    [a][2]xfade=transition=fade:duration=1:offset=8[b];\
    [b][3]xfade=transition=fade:duration=1:offset=12[c];\
    [c][4]xfade=transition=fade:duration=1:offset=16[d];\
    [d][5]xfade=transition=fade:duration=1:offset=20,format=yuv420p[v]" \
  -map "[v]" -an -c:v libx264 -preset slow -crf 19 -movflags +faststart \
  "$OUT/hero.mp4"

cp "$WORK/f1.jpg" "$OUT/hero-poster.jpg"
echo "Wrote $OUT/hero.mp4"
ls -lh "$OUT/hero.mp4"
