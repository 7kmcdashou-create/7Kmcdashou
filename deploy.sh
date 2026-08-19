#!/bin/bash
set -e
LOG="/tmp/hermes-deploy.log"
echo "=== Hermes Deploy $(date) ===" > "$LOG"
exec >> "$LOG" 2>&1

echo "Waiting for Docker daemon..."
for i in $(seq 1 60); do
    if sudo docker info &>/dev/null; then
        echo "Docker ready after $((i*3))s"
        break
    fi
    sleep 3
done

echo "Pulling Hermes Agent image..."
sudo docker pull ghcr.io/nousresearch/hermes-agent:v0.20.4

echo "Starting container..."
cd /workspaces/7Kmcdashou
sudo docker compose up -d

echo "Waiting for dashboard on port 9119..."
for i in $(seq 1 60); do
    if curl -sf http://localhost:9119 >/dev/null 2>&1; then
        echo "Dashboard ready after $((i*3))s!"
        break
    fi
    sleep 3
done

echo "=== Deploy complete $(date) ==="
