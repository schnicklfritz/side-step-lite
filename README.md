# Side-Step QuickPod Template

QuickPod should pull this image from Docker Hub through the **Docker Image Path** field.
This image is meant for **SSH Entry** mode so you can log in and run Side-Step manually.

## What this image includes
- NVIDIA CUDA base image
- Python 3.11
- Git
- ffmpeg
- OpenSSH
- uv
- Side-Step cloned to `/opt/Side-Step`
- Side-Step dependencies installed with `uv sync`

## Required GitHub repo secrets
- DOCKERHUB_USERNAME
- DOCKERHUB_TOKEN

## Build behavior
The GitHub Action builds and pushes to Docker Hub on every push.

## Suggested QuickPod template settings

### Template Name
Side-Step Trainer

### Docker Image Path
YOUR_DOCKERHUB_USERNAME/sidestep:latest

### Launch Mode
SSH Entry

### Docker Options
```bash
--gpus all \
--runtime=nvidia \
-p 22:22 \
-v /workspace:/workspace \
-e NVIDIA_VISIBLE_DEVICES=all \
--shm-size=8gb
```

### Optional On Start Script
```bash
mkdir -p /workspace/input /workspace/output /models/checkpoints
nvidia-smi || true
```

## First commands after SSH login
```bash
cd /opt/Side-Step
uv run python train.py
```

## Notes
- Keep checkpoints outside the image if possible.
- Use `/workspace` for anything you want preserved on standard pods.
- Pin `SIDESTEP_REF` once you know the exact working branch or commit.
