#!/bin/bash
set -x
exec > /tmp/hermes-start.log 2>&1
echo "=== Start $(date) ==="
pkill -f 'hermes dashboard' 2>/dev/null || true
pkill -f cloudflared 2>/dev/null || true
sleep 1
nohup hermes dashboard --host 0.0.0.0 --port 9119 --skip-build --no-open > /tmp/hermes-dashboard.log 2>&1 &
echo "Dashboard PID: $!"
sleep 5
nohup cloudflared tunnel --url http://localhost:9119 > /tmp/cf.log 2>&1 &
echo "CF PID: $!"
TUNNEL_URL=""
for i in $(seq 1 20); do
  sleep 3
  TUNNEL_URL=$(grep -oE 'https://[a-z0-9-]+\.trycloudflare\.com' /tmp/cf.log | head -1)
  [ -n "$TUNNEL_URL" ] && break
done
if [ -n "$TUNNEL_URL" ]; then
  echo "TUNNEL: $TUNNEL_URL"
  ENCODED=$(python3 -c "import base64; print(base64.b64encode(b'$TUNNEL_URL').decode())")
  curl -s -X PUT -H "Authorization: token $GITHUB_TOKEN"     -H "Content-Type: application/json"     "https://api.github.com/repos/7kmcdashou-create/7Kmcdashou/contents/.tunnel-url"     -d '{"message":"tunnel","content":"'"$ENCODED"'"}'
fi
echo "=== Done $(date) ==="
