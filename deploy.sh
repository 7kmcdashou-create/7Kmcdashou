#!/bin/bash
DEPLOY_LOG="/tmp/hermes-deploy.log"
echo "=== Hermes Agent Auto-Deploy ===" > $DEPLOY_LOG
echo "$(date): Starting deploy..." >> $DEPLOY_LOG

# Wait for Docker-in-Docker feature to be ready
for i in $(seq 1 90); do
    sudo docker info &>/dev/null && break
    sleep 3
done
echo "$(date): Docker ready" >> $DEPLOY_LOG

# Pull image
echo "$(date): Pulling Hermes Agent image..." >> $DEPLOY_LOG
sudo docker pull ghcr.io/nousresearch/hermes-agent:v0.20.4 >> $DEPLOY_LOG 2>&1
echo "$(date): Image pulled" >> $DEPLOY_LOG

# Start
cd /workspaces/7Kmcdashou
sudo docker compose up -d >> $DEPLOY_LOG 2>&1
echo "$(date): Container started" >> $DEPLOY_LOG

# Health check
sleep 8
if sudo docker ps | grep -q hermes-agent; then
    echo "$(date): SUCCESS - Hermes Agent running on port 9119" >> $DEPLOY_LOG
else
    echo "$(date): WARNING - checking logs..." >> $DEPLOY_LOG
    sudo docker ps -a >> $DEPLOY_LOG 2>&1
    sudo docker logs hermes-agent --tail 30 >> $DEPLOY_LOG 2>&1
fi
