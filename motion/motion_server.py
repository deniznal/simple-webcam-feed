import eventlet
eventlet.monkey_patch()  # Make sure to do this before anything else

from flask import Flask, render_template
from flask_socketio import SocketIO
from flask_cors import CORS
import cv2
import numpy as np
import time

app = Flask(__name__)
CORS(app, resources={r"/*": {"origins": "*"}})

socketio = SocketIO(app, cors_allowed_origins="*")

# Motion detection logic
def detect_motion(frame, previous_frame):
    gray = cv2.cvtColor(frame, cv2.COLOR_BGR2GRAY)
    gray = cv2.GaussianBlur(gray, (21, 21), 0)

    if previous_frame is None:
        return False, gray

    frame_delta = cv2.absdiff(previous_frame, gray)
    thresh = cv2.threshold(frame_delta, 25, 255, cv2.THRESH_BINARY)[1]
    thresh = cv2.dilate(thresh, None, iterations=2)

    contours, _ = cv2.findContours(thresh.copy(), cv2.RETR_EXTERNAL, cv2.CHAIN_APPROX_SIMPLE)

    for contour in contours:
        if cv2.contourArea(contour) > 800:
            return True, gray

    return False, gray

# Handle motion alert
def handle_motion_alert():
    socketio.emit('motion_detected', {'message': 'Motion detected!'})

# Route to render the HTML page
@app.route('/')
def index():
    return render_template('index.html')

# Video feed capturing and motion detection
def main():
    cap = cv2.VideoCapture("http://localhost:8000/dash/manifest.mpd")

    previous_frame = None
    frame_rate = 15  # Adjust this according to the actual frame rate of your video stream

    while True:
        start_time = time.time()
        ret, frame = cap.read()
        if not ret:
            print("Failed to grab frame.")
            break

        motion_detected, previous_frame = detect_motion(frame, previous_frame)

        if motion_detected:
            handle_motion_alert()

        #cv2.imshow('Video Feed', frame)

        elapsed_time = time.time() - start_time
        wait_time = max(1.0 / frame_rate - elapsed_time, 0)  # Adjust sleep time based on frame rate
        time.sleep(wait_time)

        if cv2.waitKey(1) & 0xFF == ord('q'):
            break

        

    cap.release()
    cv2.destroyAllWindows()

# Main eventlet greenlet
def start_video_thread():
    socketio.start_background_task(main)

if __name__ == '__main__':
    start_video_thread()
    socketio.run(app, host='0.0.0.0', port=5000)
