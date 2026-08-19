#!/bin/bash
DEPLOY_LOG="/tmp/hermes-deploy.log"
echo "=== Hermes Agent Auto-Deploy ===" > $DEPLOY_LOG
echo "$(date): Starting..." >> $DEPLOY_LOG
for i in $(seq 1 90); do
    sudo docker info &>/dev/null && break
    sleep 3
done
echo "$(date): Docker ready" >> $DEPLOY_LOG
echo "$(date): Pulling image..." >> $DEPLOY_LOG
sudo docker pull ghcr.io/nousresearch/hermes-agent:v0.20.4 >> $DEPLOY_LOG 2>&1
echo "$(date): Image pulled" >> $DEPLOY_LOG
cd /workspaces/7Kmcdashou
sudo docker compose up -d >> $DEPLOY_LOG 2>&1
echo "$(date): Container started" >> $DEPLOY_LOG
sleep 8
if sudo docker ps | grep -q hermes-agent; then
    echo "$(date): SUCCESS" >> $DEPLOY_LOG
else
    echo "$(date): WARNING" >> $DEPLOY_LOG
    sudo docker ps -a >> $DEPLOY_LOG 2>&1
    sudo docker logs hermes-agent --tail 30 >> $DEPLOY_LOG 2>&1
fi
