#!/bin/bash
# Hermes Agent + hermes-web-ui auto-start
# Runs as postCreateCommand in Codespace

LOG=/tmp/hermes_setup.log
echo "=== $(date) Setup started ===" > $LOG

# Wait for Docker daemon
echo "Waiting for Docker daemon..." >> $LOG
i=0
while [ $i -lt 120 ]; do
  if docker info >/dev/null 2>&1; then
    echo "Docker ready after $((i*3))s" >> $LOG
    break
  fi
  i=$((i+1))
  sleep 3
done

if ! docker info >/dev/null 2>&1; then
  echo "ERROR: Docker never came up" >> $LOG
  exit 0
fi

# Start Hermes Agent container
echo "Starting Hermes Agent container..." >> $LOG
cd /workspaces/7Kmcdashou
docker compose up -d >> $LOG 2>&1

echo "Waiting 15s for container..." >> $LOG
sleep 15
docker ps -a >> $LOG 2>&1

# Install hermes-web-ui
echo "Installing hermes-web-ui..." >> $LOG
npm install -g hermes-web-ui >> $LOG 2>&1

# Start hermes-web-ui
echo "Starting hermes-web-ui on 8648..." >> $LOG
nohup hermes-web-ui start 8648 --no-open >> $LOG 2>&1 &
sleep 5

# Report
echo "Port check:" >> $LOG
ss -tlnp >> $LOG 2>&1 || true
echo "=== $(date) Setup finished ===" >> $LOG
