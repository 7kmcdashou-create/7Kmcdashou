#!/bin/bash
DEPLOY_LOG="/tmp/hermes-deploy.log"
echo "=== Hermes Agent Deploy ===" > $DEPLOY_LOG
echo "$(date): Starting..." >> $DEPLOY_LOG

# Wait for Docker-in-Docker
for i in $(seq 1 90); do
    sudo docker info &>/dev/null && break
    sleep 3
done
echo "$(date): Docker ready" >> $DEPLOY_LOG

# Pull Hermes Agent image
sudo docker pull ghcr.io/nousresearch/hermes-agent:v0.20.4 >> $DEPLOY_LOG 2>&1
echo "$(date): Image pulled" >> $DEPLOY_LOG

# Start container
cd /workspaces/7Kmcdashou
sudo docker compose up -d >> $DEPLOY_LOG 2>&1
echo "$(date): Container started" >> $DEPLOY_LOG

# Wait for dashboard to be ready
for i in $(seq 1 60); do
    curl -s -o /dev/null http://localhost:9119 2>/dev/null && break
    sleep 3
done
echo "$(date): Dashboard ready on :9119" >> $DEPLOY_LOG

# Install cloudflared
echo "$(date): Installing cloudflared..." >> $DEPLOY_LOG
curl -sL https://github.com/cloudflare/cloudflared/releases/latest/download/cloudflared-linux-amd64 -o /tmp/cloudflared 2>>$DEPLOY_LOG
chmod +x /tmp/cloudflared 2>>$DEPLOY_LOG

# Start quick tunnel (no account needed)
echo "$(date): Starting Cloudflare tunnel..." >> $DEPLOY_LOG
CF_LOG="/tmp/cloudflared.log"
nohup /tmp/cloudflared tunnel --url http://localhost:9119 > $CF_LOG 2>&1 &

# Wait for tunnel URL
echo "$(date): Waiting for tunnel URL..." >> $DEPLOY_LOG
for i in $(seq 1 60); do
    CF_URL=$(grep -oP 'https://[a-z0-9\-]+\.trycloudflare\.com' $CF_LOG 2>/dev/null | head -1)
    if [ -n "$CF_URL" ]; then
        echo "PUBLIC_URL:$CF_URL" > /tmp/hermes-public-url.txt
        echo "$(date): TUNNEL_READY:$CF_URL" >> $DEPLOY_LOG
        break
    fi
    sleep 3
done
if [ ! -f /tmp/hermes-public-url.txt ]; then
    echo "$(date): WARNING - tunnel URL not found yet" >> $DEPLOY_LOG
    cat $CF_LOG >> $DEPLOY_LOG 2>&1
fi
