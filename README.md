# 🎥 Real-Time Webcam Streaming & Motion Detection

This project captures video from your webcam, streams it in real-time using MPEG-DASH, and detects motion using OpenCV. When motion is detected, it triggers a sound alert and a message on the web interface.

---

## ✅ Features

- Live webcam streaming with FFmpeg and DASH
- Motion detection using OpenCV
- Sound + browser alerts when motion is detected
- Web player with:
  - Play / Pause / Go Live / Rewind
  - Screenshot button
  - Live delay indicator

---

## 🔧 Requirements

Make sure you have the following:

- Python 3
- FFmpeg
- v4l2 (Linux webcam access)
- ALSA (Linux audio capture)
- `xdg-open` or `open` (to open browser)

### Install Python dependencies:

```bash
pip install flask flask-socketio flask-cors eventlet opencv-python
