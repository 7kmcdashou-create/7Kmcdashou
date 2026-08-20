#!/bin/bash
set -x

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
nohup cloudflared tunnel --url http://localhost:9119 > /tmp/cloudflared.log 2>&1 &
echo "Cloudflared PID: $!"

# Wait for cloudflared to start and capture the URL (try up to 30s)
for i in $(seq 1 6); do
    sleep 5
    TUNNEL_URL=$(grep -oE 'https://[a-z0-9-]+[.]trycloudflare[.]com' /tmp/cloudflared.log 2>/dev/null | head -1)
    echo "Attempt $i: TUNNEL_URL=$TUNNEL_URL"
    if [ -n "$TUNNEL_URL" ]; then
        break
    fi
done

if [ -n "$TUNNEL_URL" ]; then
    echo "TUNNEL_URL=$TUNNEL_URL" > /tmp/tunnel-url.txt
    echo "Tunnel ready: $TUNNEL_URL"
    
    # Push tunnel URL via gh api (codespace gh is pre-authenticated)
    ENCODED_URL=$(echo -n "$TUNNEL_URL" | base64 -w 0)
    gh api -X PUT repos/7kmcdashou-create/7Kmcdashou/contents/.tunnel-url         -f message="tunnel: update url"         -f content="$ENCODED_URL"         >> /tmp/hermes-start.log 2>&1
    echo "gh api push result: $?"
else
    echo "WARNING: No tunnel URL found after 30s"
    echo "--- cloudflared.log ---"
    cat /tmp/cloudflared.log 2>&1
    echo "--- dashboard log ---"
    tail -5 /tmp/hermes-dashboard.log 2>&1
    which cloudflared && echo "cloudflared OK" || echo "cloudflared MISSING"
    which hermes && echo "hermes OK" || echo "hermes MISSING"
fi

echo "=== Hermes start completed ==="