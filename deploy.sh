#!/bin/bash
# Auto-deploy Hermes Agent v0.20.4
set -e
DEPLOY_LOG="/tmp/hermes-deploy.log"
echo "=== Hermes Agent Auto-Deploy ===" > $DEPLOY_LOG
echo "$(date): Starting deploy..." >> $DEPLOY_LOG

# Wait for Docker
for i in $(seq 1 60); do
    docker info &>/dev/null && break
    sleep 2
done
echo "$(date): Docker ready" >> $DEPLOY_LOG

# Pull image
docker pull ghcr.io/nousresearch/hermes-agent:v0.20.4 >> $DEPLOY_LOG 2>&1
echo "$(date): Image pulled" >> $DEPLOY_LOG

# Start
cd /workspaces/7Kmcdashou
docker compose up -d >> $DEPLOY_LOG 2>&1
echo "$(date): Container started" >> $DEPLOY_LOG

# Health check
sleep 5
if docker ps | grep -q hermes-agent; then
    echo "$(date): SUCCESS - Hermes Agent running on port 9119" >> $DEPLOY_LOG
else
    echo "$(date): WARNING - container may still be starting" >> $DEPLOY_LOG
    docker logs hermes-agent --tail 20 >> $DEPLOY_LOG 2>&1
fi
