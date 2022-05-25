#!/bin/bash

[ -z $1 ] && { echo Variable filename required.; exit 1; }
[ -f $1 ] || { echo filename not exists; exit 1; }
[ -z $2 ] && { echo Variable rotate degree required; exit 1; }
command -v "ffmpeg" >/dev/null || { echo "ffmpeg command not found."; exit 1; }

input="$1"
ffmpeg -i "$input" -c copy -metadata:s:v:0 rotate="$2" "$input".output.mp4
touch -r "$input" "$input".output.mp4
mv "$input" "$input".delete.me.mp4
mv "$input".output.mp4 "$input"
