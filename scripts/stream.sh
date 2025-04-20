#!/bin/bash

# Load config
source ./config/settings.sh

# Ensure output directory exists
mkdir -p "$OUTPUT_DIR"
# Start streaming
ffmpeg -f v4l2 -framerate 15 -video_size 640x360 -i "$VIDEO_DEVICE" \
       -f alsa -i "$AUDIO_DEVICE" \
       -c:v libx264 -preset ultrafast -tune zerolatency \
       -profile:v main -level 3.1 -b:v 300k \
       -pix_fmt yuv420p \
       -c:a aac -b:a 128k \
       -f dash \
       -seg_duration "$SEGMENT_DURATION" \
       -frag_duration 500 \
       -g 15 -keyint_min 15 -sc_threshold 0 \
       -use_timeline 1 -use_template 1 \
       -window_size 5 -extra_window_size 5 \
       -remove_at_exit 1 \
       -s:v:0 640x360 -b:v:0 300k \
       -s:v:1 320x180 -b:v:1 200k \
       -s:v:2 160x90 -b:v:2 100k \
       "$OUTPUT_DIR/manifest.mpd" 

