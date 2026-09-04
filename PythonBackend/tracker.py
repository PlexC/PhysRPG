import cv2
import urllib.request
import os
import mediapipe as mp
from mediapipe.tasks import python
from mediapipe.tasks.python import vision
from mediapipe.tasks.python.vision import drawing_utils
from mediapipe.tasks.python.vision import drawing_styles

# 1. Download Model
model_path = 'pose_landmarker.task'
if not os.path.exists(model_path):
    print("Downloading MediaPipe AI model...")
    url = "https://storage.googleapis.com/mediapipe-models/pose_landmarker/pose_landmarker_heavy/float16/1/pose_landmarker_heavy.task"
    urllib.request.urlretrieve(url, model_path)

base_options = python.BaseOptions(model_asset_path=model_path)
options = vision.PoseLandmarkerOptions(
    base_options=base_options,
    output_segmentation_masks=False,
    running_mode=vision.RunningMode.VIDEO)
detector = vision.PoseLandmarker.create_from_options(options)

# 2. Analyze the video and SHOW the UI
def analyze_workout(video_path: str) -> int:
    cap = cv2.VideoCapture(video_path)
    if not cap.isOpened():
        print(f"Error: Could not open video {video_path}")
        return 50 
        
    fps = cap.get(cv2.CAP_PROP_FPS)
    if fps == 0 or fps != fps:
        fps = 30 
        
    # Calculate delay to play video at normal speed (in milliseconds)
    frame_delay = int(1000 / fps) 
        
    frame_index = 0
    total_movement = 0.0
    detected_frames = 0

    while cap.isOpened():
        success, frame = cap.read()
        if not success:
            break
            
        timestamp_ms = int(1000 * frame_index / fps)
        frame_index += 1

        rgb_frame = cv2.cvtColor(frame, cv2.COLOR_BGR2RGB)
        mp_image = mp.Image(image_format=mp.ImageFormat.SRGB, data=rgb_frame)

        # Detect poses
        detection_result = detector.detect_for_video(mp_image, timestamp_ms)

        # Draw the skeleton on the frame!
        if detection_result.pose_landmarks:
            for pose_landmarks in detection_result.pose_landmarks:
                drawing_utils.draw_landmarks(
                    frame,
                    pose_landmarks,
                    vision.PoseLandmarksConnections.POSE_LANDMARKS,
                    drawing_styles.get_default_pose_landmarks_style()
                )
                
                # Math for the score
                left_shoulder_y = pose_landmarks[11].y
                total_movement += abs(left_shoulder_y)
                detected_frames += 1

        # FOR THE DEMO: Show the video frame with the skeleton
        cv2.imshow("Hack for Humanity AI Form Tracker", frame)
        
        # Wait just long enough to match the video's FPS. 
        # (Pressing 'q' manually skips the video if you want)
        if cv2.waitKey(frame_delay) & 0xFF == ord('q'):
            break

    # Clean up the windows when the video finishes
    cap.release()
    cv2.destroyAllWindows()
    
    # Generate the final score
    if detected_frames > 0:
        score = min(max(int((total_movement / detected_frames) * 150), 60), 100)
    else:
        score = 40 
        
    print(f"MediaPipe Evaluation Complete. Final Score: {score}")
    return score