#!/bin/bash
exec >> /tmp/hermes-deploy.log 2>&1
echo "=== Deploy $(date) ==="

for i in $(seq 1 60); do sudo docker info &>/dev/null && break; sleep 3; done
echo "Docker ready"

sudo docker pull ghcr.io/nousresearch/hermes-agent:v0.20.4
cd /workspaces/7Kmcdashou
sudo docker compose up -d

for i in $(seq 1 60); do curl -sf http://localhost:9119 >/dev/null 2>&1 && break; sleep 3; done
echo "Dashboard ready"

curl -sL https://github.com/cloudflare/cloudflared/releases/latest/download/cloudflared-linux-amd64 -o /usr/local/bin/cloudflared && chmod +x /usr/local/bin/cloudflared

cloudflared tunnel --url http://localhost:9119 > /tmp/cf_output.log 2>&1 &
echo "Tunnel starting..."

for i in $(seq 1 80); do
 CF_URL=$(grep -o "https://[a-z0-9-]*trycloudflare.com" /tmp/cf_output.log 2>/dev/null | head -1)
 if [ -n "$CF_URL" ]; then
  echo "URL: $CF_URL"
  echo "$CF_URL" > /workspaces/7Kmcdashou/PUBLIC_URL.txt
  cd /workspaces/7Kmcdashou
  git config user.email "h@b" && git config user.name "H"
  git add PUBLIC_URL.txt && git commit -m "t" 2>/dev/null && git push 2>/dev/null
  echo "=== SUCCESS $(date) ==="
  exit 0
 fi
 sleep 3
done
echo "=== FAILED ==="
