#!/bin/bash

echo "=== Hermes start at $(date) ==="

# Kill any existing dashboard
pkill -f "hermes dashboard" 2>/dev/null || true
sleep 1

# Start hermes dashboard on 0.0.0.0:9119
# --skip-build: use pre-built web_dist (no npm needed)
# --no-open: don't try to open browser
# --host 0.0.0.0: bind to all interfaces (required for Codespace port forwarding)
nohup hermes dashboard --host 0.0.0.0 --port 9119 --no-open --skip-build >> /tmp/hermes-dashboard.log 2>&1 &

echo "Dashboard PID: $!"
echo "=== Hermes start completed ==="
