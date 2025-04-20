#!/bin/bash

# Load settings
source ./config/settings.sh

# Define the motion detection script
MOTION_SCRIPT="./motion/motion_server.py"

# Start or reload NGINX
if pgrep nginx > /dev/null; then
  echo "[*] NGINX is already running. Reloading config..."
  sudo systemctl restart nginx
else
  echo "[+] Starting NGINX..."
  sudo -p nginx -p $(pwd)/nginx -c nginx.conf

fi

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
       "$OUTPUT_DIR/manifest.mpd" &

FFMPEG_PID=$!

sleep 15

# Start motion detection
echo "[+] Starting motion detection..."
python3 ./motion/motion_server.py &

MOTION_PID=$!

# Give a few seconds for everything to start up
sleep 3

# Open browser to the app
echo "[+] Opening browser to http://localhost:8000"
xdg-open "http://localhost:8000" &>/dev/null || open "http://localhost:8000"

# Wait for FFmpeg process to end
wait $FFMPEG_PID

# Cleanup on exit
echo "[+] Cleaning up..."
kill $MOTION_PID 2>/dev/null
