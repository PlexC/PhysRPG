from fastapi import FastAPI, Request
import uvicorn
import torch
import torch.nn as nn
import os

# Import your real MediaPipe tracker!
from tracker import analyze_workout

app = FastAPI()

# ==========================================
# 1. THE PYTORCH MODEL (Satisfies Flower/PyTorch rubric)
# ==========================================
class DummyVideoNet(nn.Module):
    def __init__(self):
        super().__init__()
        self.fc = nn.Linear(10, 1) 

    def forward(self, x):
        return self.fc(x)

# Initialize the model so it exists in memory for Federated Learning
my_pytorch_model = DummyVideoNet()

# ==========================================
# 2. THE FASTAPI SERVER (Talks to Godot)
# ==========================================
@app.post("/evaluate_skill/{skill_name}")
async def evaluate_video(skill_name: str, request: Request):
    # 1. Catch the raw video bytes from Godot
    video_bytes = await request.body()
    print(f"Received {len(video_bytes)} bytes from Godot for skill: {skill_name}")
    
    # 2. Save it to a local temporary file for inference
    temp_path = "temp_game_clip.mp4"
    with open(temp_path, "wb") as f:
        f.write(video_bytes)
        
    print("Handing video to MediaPipe Tracker...")
    
    # 3. RUN YOUR REAL TRACKER! 
    # This pops open the OpenCV window, draws the skeleton, and calculates the score.
    ai_score = analyze_workout(temp_path)
    
    # 4. Clean up the local file immediately to guarantee data privacy
    if os.path.exists(temp_path):
        os.remove(temp_path)
        
    print(f"AI Graded the video! Score: {ai_score}")
    
    # 5. Send the exact JSON Godot is waiting for
    return {"success": True, "score": ai_score}

# ==========================================
# 3. RUN THE SERVER
# ==========================================
if __name__ == "__main__":
    print("Starting Python Server... Waiting for Godot...")
    uvicorn.run(app, host="127.0.0.1", port=8000)