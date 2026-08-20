#!/bin/bash
LOG=/tmp/hermes_setup.log
echo "=== $(date) Setup started ===" > $LOG

# Install Docker CE
echo "Installing Docker CE..." >> $LOG
sudo apt-get update >> $LOG 2>&1
sudo apt-get install -y apt-transport-https ca-certificates curl gnupg lsb-release >> $LOG 2>&1
curl -fsSL https://get.docker.com | sudo bash >> $LOG 2>&1
sudo usermod -aG docker vscode >> $LOG 2>&1

# Wait for docker
echo "Waiting for Docker daemon..." >> $LOG
for i in $(seq 1 30); do
  sudo docker info >/dev/null 2>&1 && echo "Docker ready" >> $LOG && break
  sleep 2
done

# Start Hermes Agent container
echo "Starting Hermes Agent..." >> $LOG
cd /workspaces/7Kmcdashou
sudo docker compose up -d >> $LOG 2>&1
sleep 10
sudo docker ps >> $LOG 2>&1

# Install hermes-web-ui
echo "Installing hermes-web-ui..." >> $LOG
npm install -g hermes-web-ui >> $LOG 2>&1
hermes-web-ui start 8648 --no-open >> $LOG 2>&1 &
sleep 5

# Report
ss -tlnp >> $LOG 2>&1
echo "=== $(date) Done ===" >> $LOG
