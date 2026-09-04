# PhysRPG

**Gamify tedious physical therapy! A privacy-first RPG for chronic pain and injuries that uses local edge AI to score your real-world movements.**

[![Devpost](https://img.shields.io/badge/Devpost-Hack_for_Humanity-blue)](https://devpost.com/)
[![Godot Engine](https://img.shields.io/badge/Godot_4-GDScript-478cbf?logo=godotengine&logoColor=white)](https://godotengine.org/)
[![Python](https://img.shields.io/badge/Python_3-FastAPI-3776AB?logo=python&logoColor=white)](https://www.python.org/)

*Built for the Hack for Humanity | Summer 2026 Hackathon.*

---

## The Problem
Physical therapy, rehabilitation, and routine fitness suffer from massive abandonment rates due to the sheer tedium of repetitive exercises and the high cost of clinic visits. Furthermore, modern computer vision fitness apps often require users to stream sensitive, unencrypted video of their living rooms and bodies to centralized cloud servers, posing severe biometric privacy risks.

## Our Solution
**PhysRPG** is a retro RPG that turns physical therapy into an accessible adventure. Using an Active Time Battle (ATB) system, combat actions (like "Punch" or "Kick") require physical stamina. 

To protect user privacy, 100% of the video processing happens locally on the user's device via an Edge AI microservice. By coupling gamified habit loops with zero-knowledge biometric privacy and Federated Learning architecture, we make physical recovery accessible, cheap, and rewarding.

---

## 🏗️ System Architecture

Our decoupled architecture ensures that **zero biometric frames ever leave the user's hardware**.

```text
[ Player Video ] ──> [ Godot HTTPRequest ] ──> [ Local FastAPI (Port 8000) ]
                                                          │
                               ┌──────────────────────────┴──────────────────────────┐
                               ▼                                                     ▼
                    [ 1. Motion Tracker ]                                 [ 2. Flower FL Client ]
                 Local PyTorch / MediaPipe                               Local On-Device Training
              (Calculates Form Score: 0-100)                             (Calculates Weight Deltas)
                               │                                                     │
                               ▼                                                     ▼
                     [ Game Action / ATB ]                                [ Flower Central Server ]
                     (Punch, Squat, Heal)                                   (Aggregates via FedAvg)
                                                                           *ZERO raw video uploaded*
