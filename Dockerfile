FROM nvidia/cuda:12.8.1-cudnn-devel-ubuntu22.04

ENV DEBIAN_FRONTEND=noninteractive \
    PYTHONUNBUFFERED=1 \
    UV_LINK_MODE=copy \
    UV_COMPILE_BYTECODE=1 \
    UV_PROJECT_ENVIRONMENT=/opt/venv \
    PATH=/opt/venv/bin:/root/.local/bin:${PATH} \
    SIDESTEP_HOME=/opt/Side-Step \
    SIDESTEP_CONFIG_DIR=/root/.config/sidestep \
    SIDESTEP_CHECKPOINTS=/models/checkpoints

RUN apt-get update && apt-get install -y --no-install-recommends \
    software-properties-common \
    ca-certificates \
    curl \
    git \
    ffmpeg \
    build-essential \
    pkg-config \
    && add-apt-repository ppa:deadsnakes/ppa \
    && apt-get update && apt-get install -y --no-install-recommends \
    python3.11 \
    python3.11-dev \
    python3.11-venv \
    && rm -rf /var/lib/apt/lists/*

RUN ln -sf /usr/bin/python3.11 /usr/bin/python3
RUN curl -LsSf https://astral.sh/uv/install.sh | sh

WORKDIR /opt

ARG SIDESTEP_REPO=https://github.com/koda-dernet/Side-Step.git
ARG SIDESTEP_REF=main

RUN git clone --depth 1 --branch "${SIDESTEP_REF}" "${SIDESTEP_REPO}" "${SIDESTEP_HOME}"

WORKDIR ${SIDESTEP_HOME}
RUN uv sync

RUN mkdir -p /workspace/input /workspace/output /models/checkpoints /root/.config/sidestep

VOLUME ["/workspace", "/models", "/root/.config/sidestep"]

WORKDIR /workspace

RUN printf '%s\n' \
  '#!/usr/bin/env bash' \
  'set -euo pipefail' \
  'mkdir -p /root/.config/sidestep /workspace/input /workspace/output /models/checkpoints' \
  'cd /opt/Side-Step' \
  'if [ "${1:-}" = "train" ]; then shift; exec uv run python train.py "$@"; fi' \
  'if [ "${1:-}" = "wizard" ]; then shift; exec uv run python train.py "$@"; fi' \
  'exec "$@"' \
  > /usr/local/bin/entrypoint.sh \
  && chmod +x /usr/local/bin/entrypoint.sh

ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
CMD ["bash"]
