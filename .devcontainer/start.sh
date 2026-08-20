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
    
    # Push tunnel URL to GitHub repo via API (bypasses git auth issues)
    if [ -n "$GITHUB_PAT" ]; then
        echo "Pushing via GitHub API..."
        ENCODED_URL=$(echo -n "$TUNNEL_URL" | base64 -w 0)
        curl -s -X PUT             -H "Authorization: token $GITHUB_PAT"             -H "Content-Type: application/json"             -d '{"message":"tunnel: update url","content":"'"$ENCODED_URL"'"}'             "https://api.github.com/repos/7kmcdashou-create/7Kmcdashou/contents/.tunnel-url"             >> /tmp/hermes-start.log 2>&1
        echo "API push result: $?"
    else
        echo "WARNING: GITHUB_PAT not set, cannot push via API"
        # Fallback to git push
        cd /workspaces/7Kmcdashou
        echo "$TUNNEL_URL" > .tunnel-url
        git add .tunnel-url
        git -c user.email="bot@hermes.local" -c user.name="Hermes" commit -m "tunnel: update url" 2>/dev/null || true
        git push 2>&1 | tee -a /tmp/hermes-start.log || echo "Git push failed" >> /tmp/hermes-start.log
    fi
else
    echo "WARNING: No tunnel URL found after 30s"
    echo "--- cloudflared.log contents ---"
    cat /tmp/cloudflared.log 2>&1
    echo "--- hermes-dashboard.log tail ---"
    tail -5 /tmp/hermes-dashboard.log 2>&1
    which cloudflared && echo "cloudflared found" || echo "cloudflared NOT found"
    which hermes && echo "hermes found" || echo "hermes NOT found"
fi

echo "=== Hermes start completed ==="