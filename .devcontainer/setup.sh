#!/bin/bash
LOG=/tmp/hermes_setup.log
echo "=== $(date) Setup started ===" > $LOG

# Phase 1: Install Docker CE
if ! command -v docker &>/dev/null; then
  echo "Installing Docker CE..." >> $LOG
  apt-get update -qq >> $LOG 2>&1 || true
  apt-get install -y -qq apt-transport-https ca-certificates curl gnupg lsb-release >> $LOG 2>&1 || true
  curl -fsSL https://get.docker.com -o /tmp/get-docker.sh >> $LOG 2>&1
  if [ -f /tmp/get-docker.sh ]; then
    sudo bash /tmp/get-docker.sh >> $LOG 2>&1 || true
  else
    echo "Failed to download Docker install script" >> $LOG
    # Fallback: install from Ubuntu repo
    sudo apt-get install -y -qq docker.io >> $LOG 2>&1 || true
  fi
  sudo usermod -aG docker vscode >> $LOG 2>&1 || true
  echo "Docker install attempted" >> $LOG
else
  echo "Docker already present" >> $LOG
fi

# Phase 2: Wait for Docker daemon (up to 60s)
echo "Waiting for Docker daemon..." >> $LOG
DOCKER_READY=0
for i in $(seq 1 60); do
  if sudo docker info >/dev/null 2>&1; then
    DOCKER_READY=1
    echo "Docker daemon ready after ${i}s" >> $LOG
    break
  fi
  sleep 1
done

if [ "$DOCKER_READY" = "0" ]; then
  echo "WARNING: Docker daemon not ready after 60s" >> $LOG
  # Try starting it manually
  sudo dockerd >> $LOG 2>&1 &
  sleep 5
fi

# Phase 3: Start Hermes Agent container
echo "Starting Hermes Agent..." >> $LOG
cd /workspaces/7Kmcdashou || true
sudo docker compose pull >> $LOG 2>&1 || true
sudo docker compose up -d >> $LOG 2>&1 || true

# Wait for container to be running
echo "Waiting for Hermes container..." >> $LOG
for i in $(seq 1 30); do
  if sudo docker ps | grep -q hermes-agent >> $LOG 2>&1; then
    echo "Hermes container running" >> $LOG
    break
  fi
  sleep 2
done

# Phase 4: Install and start hermes-web-ui
echo "Installing hermes-web-ui..." >> $LOG
npm install -g hermes-web-ui >> $LOG 2>&1 || true

# Start web UI in background
nohup hermes-web-ui start 8648 --no-open >> $LOG 2>&1 &
sleep 8

# Phase 5: Final status
echo "=== Final Status ===" >> $LOG
echo "Docker:" >> $LOG
sudo docker ps >> $LOG 2>&1 || true
echo "Ports:" >> $LOG
ss -tlnp >> $LOG 2>&1 || true
echo "=== $(date) Setup complete ===" >> $LOG
