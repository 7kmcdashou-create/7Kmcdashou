#!/bin/bash
LOG=/tmp/hermes_setup.log
echo "=== $(date) Setup started ===" > $LOG

# Install Docker
if ! command -v docker &>/dev/null; then
  echo "Installing Docker..." >> $LOG
  curl -fsSL https://get.docker.com | sudo bash >> $LOG 2>&1
  sudo usermod -aG docker vscode >> $LOG 2>&1
  echo "Docker installed" >> $LOG
else
  echo "Docker already installed" >> $LOG
fi

# Wait for docker daemon
echo "Waiting for Docker daemon..." >> $LOG
for i in $(seq 1 30); do
  sudo docker info >/dev/null 2>&1 && echo "Docker ready" >> $LOG && break
  sleep 2
done

# Start Hermes Agent
echo "Starting Hermes Agent container..." >> $LOG
cd /workspaces/7Kmcdashou
sudo docker compose up -d >> $LOG 2>&1
sleep 10
sudo docker ps >> $LOG 2>&1

# Install hermes-web-ui
if ! command -v hermes-web-ui &>/dev/null; then
  echo "Installing hermes-web-ui..." >> $LOG
  npm install -g hermes-web-ui >> $LOG 2>&1
fi

# Start hermes-web-ui
echo "Starting hermes-web-ui..." >> $LOG
hermes-web-ui start 8648 --no-open >> $LOG 2>&1 &
sleep 5

# Report
echo "Port check:" >> $LOG
ss -tlnp >> $LOG 2>&1
echo "=== $(date) Setup done ===" >> $LOG
