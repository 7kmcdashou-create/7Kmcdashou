#!/bin/bash

echo "=== Hermes start at $(date) ==="

# Kill any existing dashboard
pkill -f "hermes dashboard" 2>/dev/null || true
sleep 1

# Start hermes dashboard on 0.0.0.0:9119
nohup hermes dashboard --host 0.0.0.0 --port 9119 --no-open --skip-build >> /tmp/hermes-dashboard.log 2>&1 &

echo "Dashboard PID: $!"

# Wait for dashboard to start
sleep 5

# Make port 9119 publicly accessible (no GitHub login required)
# gh CLI is pre-authenticated inside Codespaces
gh codespace ports visibility 9119:public -c $CODESPACE_NAME 2>&1 || \
gh codespace ports visibility 9119:public 2>&1 || \
echo "WARN: Could not set port visibility via gh"

echo "=== Hermes start completed ==="
