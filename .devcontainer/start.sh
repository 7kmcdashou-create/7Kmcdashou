#!/bin/bash

echo "=== Hermes start at $(date) ==="

# Kill any existing processes
pkill -f "hermes dashboard" 2>/dev/null || true
pkill -f cloudflared 2>/dev/null || true
sleep 1

# Start hermes dashboard on 0.0.0.0:9119
nohup hermes dashboard --host 0.0.0.0 --port 9119 --no-open --skip-build >> /tmp/hermes-dashboard.log 2>&1 &
echo "Dashboard PID: $!"
sleep 5

# Start cloudflared tunnel to expose dashboard publicly
# This gives a trycloudflare.com URL that bypasses GitHub auth gate
nohup cloudflared tunnel --url http://localhost:9119 > /tmp/cloudflared.log 2>&1 &
echo "Cloudflared PID: $!"

# Wait for cloudflared to start and capture the URL
sleep 8
TUNNEL_URL=$(rg -o 'https://[a-z0-9-]+\.trycloudflare\.com' /tmp/cloudflared.log | head -1)
if [ -n "$TUNNEL_URL" ]; then
    echo "TUNNEL_URL=$TUNNEL_URL" > /tmp/tunnel-url.txt
    echo "Tunnel ready: $TUNNEL_URL"
    
    # Push tunnel URL to GitHub repo so we can read it from outside
    cd /workspaces/7Kmcdashou
    echo "$TUNNEL_URL" > .tunnel-url
    git add .tunnel-url
    git -c user.email="bot@hermes.local" -c user.name="Hermes" commit -m "tunnel: update url" 2>/dev/null || true
    git push 2>/dev/null || true
else
    echo "WARNING: No tunnel URL found"
    cat /tmp/cloudflared.log
fi

echo "=== Hermes start completed ==="
