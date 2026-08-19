#!/bin/bash
LOG="/tmp/hermes-tunnel.log"
echo "=== Tunnel Start $(date) ===" > "$LOG"
exec >> "$LOG" 2>&1

# Wait for dashboard
for i in $(seq 1 30); do
    if curl -sf http://localhost:9119 >/dev/null 2>&1; then
        echo "Dashboard detected, starting tunnel..."
        break
    fi
    sleep 2
done

# Install cloudflared if not present
if [ ! -x /usr/local/bin/cloudflared ]; then
    echo "Installing cloudflared..."
    curl -sL https://github.com/cloudflare/cloudflared/releases/latest/download/cloudflared-linux-amd64 -o /usr/local/bin/cloudflared
    chmod +x /usr/local/bin/cloudflared
fi

# Kill any existing cloudflared
pkill -f 'cloudflared tunnel' 2>/dev/null || true
sleep 1

echo "Starting Cloudflare Quick Tunnel..."
cloudflared tunnel --url http://localhost:9119 > /tmp/cf_output.log 2>&1 &
CF_PID=$!
echo "cloudflared PID: $CF_PID"

# Wait for tunnel URL
echo "Waiting for tunnel URL..."
for i in $(seq 1 80); do
    CF_URL=$(grep -oP 'https://[a-z0-9\-]+\.trycloudflare\.com' /tmp/cf_output.log 2>/dev/null | head -1)
    if [ -n "$CF_URL" ]; then
        echo "TUNNEL_URL=$CF_URL"
        # Write URL to workspace
        echo "$CF_URL" > /workspaces/7Kmcdashou/PUBLIC_URL.txt
        # Push to repo
        cd /workspaces/7Kmcdashou
        git config user.email "hermes@deploy.bot"
        git config user.name "Hermes Deploy"
        git add PUBLIC_URL.txt
        git commit -m "tunnel: $CF_URL" 2>/dev/null || true
        git push 2>/dev/null || true
        echo "=== Tunnel URL pushed to repo ==="
        break
    fi
    sleep 3
done

echo "=== Tunnel script done $(date) ==="
