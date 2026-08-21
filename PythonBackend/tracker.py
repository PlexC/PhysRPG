import cv2
import urllib.request
import os
import mediapipe as mp
from mediapipe.tasks import python
from mediapipe.tasks.python import vision
from mediapipe.tasks.python.vision import drawing_utils
from mediapipe.tasks.python.vision import drawing_styles

# 1. Downloading the Google MediaPipe AI model
model_path = 'pose_landmarker.task'
if not os.path.exists(model_path):
    print("Downloading MediaPipe AI model (this might take a minute)...")
    url = "https://storage.googleapis.com/mediapipe-models/pose_landmarker/pose_landmarker_heavy/float16/1/pose_landmarker_heavy.task"
    urllib.request.urlretrieve(url, model_path)
    print("Download complete!")

# 2. Set up the modern Tasks API
base_options = python.BaseOptions(model_asset_path=model_path)
options = vision.PoseLandmarkerOptions(
    base_options=base_options,
    output_segmentation_masks=False,
    running_mode=vision.RunningMode.VIDEO) # We use VIDEO mode to support webcams and video files
detector = vision.PoseLandmarker.create_from_options(options)

# 3. Open the Video File or Webcam
#input_source = "C:/Users/a/Desktop/TestVideos/workoutabs.mp4" # Change to 0 to use a live webcam
input_source = 0
cap = cv2.VideoCapture(input_source)

if not cap.isOpened():
    print(f"Error: Could not open {input_source}.")
    exit()

# Get the video's FPS for the AI's internal timing
fps = cap.get(cv2.CAP_PROP_FPS)
if fps == 0 or fps != fps: # Fallback if FPS cannot be read
    fps = 30 
frame_index = 0

print("Tracking started. Press 'q' in the video window to quit.")

while cap.isOpened():
    success, frame = cap.read()
    if not success:
        print("End of video stream.")
        break
        
    # MediaPipe Tasks API requires a timestamp for each video frame
    timestamp_ms = int(1000 * frame_index / fps)
    frame_index += 1

    # Convert the image for MediaPipe
    rgb_frame = cv2.cvtColor(frame, cv2.COLOR_BGR2RGB)
    mp_image = mp.Image(image_format=mp.ImageFormat.SRGB, data=rgb_frame)

    # 4. Detection
    detection_result = detector.detect_for_video(mp_image, timestamp_ms)

    # 5. Draw the skeleton on the video
    if detection_result.pose_landmarks:
        for pose_landmarks in detection_result.pose_landmarks:
            drawing_utils.draw_landmarks(
                frame,
                pose_landmarks,
                vision.PoseLandmarksConnections.POSE_LANDMARKS,
                drawing_styles.get_default_pose_landmarks_style()
            )
            
            # Landmark 11 is the left shoulder. Let's print its height!
            left_shoulder_y = pose_landmarks[11].y
            print(f"Shoulder Height: {left_shoulder_y:.2f}")

    cv2.imshow("MediaPipe Tracker", frame)
    if cv2.waitKey(10) & 0xFF == ord('q'):
        break

cap.release()
cv2.destroyAllWindows()
