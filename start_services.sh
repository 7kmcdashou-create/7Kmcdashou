#!/bin/bash
# Auto-start script for Hermes Agent + hermes-web-ui in Codespace
set -e

LOG="/tmp/hermes_setup.log"
echo "=== $(date) Starting setup ===" > "$LOG"

# 1. Install Hermes Agent
echo "[1/4] Installing Hermes Agent..." >> "$LOG"
if command -v hermes &>/dev/null; then
  echo "Hermes Agent already installed" >> "$LOG"
else
  curl -fsSL https://hermes-agent.nousresearch.com/install.sh | bash >> "$LOG" 2>&1
  source ~/.bashrc 2>/dev/null || true
  export PATH="$HOME/.hermes/bin:$HOME/.local/bin:$PATH"
fi

echo "[2/4] Hermes path: $(which hermes 2>/dev/null || echo 'not found')" >> "$LOG"
hermes --version >> "$LOG" 2>&1 || echo "hermes version check failed" >> "$LOG"

# 2. Install hermes-web-ui
echo "[3/4] Installing hermes-web-ui..." >> "$LOG"
if command -v hermes-web-ui &>/dev/null; then
  echo "hermes-web-ui already installed" >> "$LOG"
else
  npm install -g hermes-web-ui >> "$LOG" 2>&1
fi

echo "hermes-web-ui version: $(hermes-web-ui --version 2>/dev/null || echo 'unknown')" >> "$LOG"

# 3. Start hermes-web-ui on port 8648 (background)
echo "[4/4] Starting hermes-web-ui..." >> "$LOG"
export PATH="$HOME/.hermes/bin:$HOME/.local/bin:$PATH"
hermes-web-ui start 8648 --no-open >> "$LOG" 2>&1 &
WEBUI_PID=$!
echo "hermes-web-ui PID: $WEBUI_PID" >> "$LOG"

# Wait a moment for it to start
sleep 5

# Check status
hermes-web-ui status >> "$LOG" 2>&1 || true

# 4. Verify ports
echo "=== Port check ===" >> "$LOG"
ss -tlnp 2>/dev/null | grep -E '8648|9119' >> "$LOG" || netstat -tlnp 2>/dev/null | grep -E '8648|9119' >> "$LOG" || echo "ss/netstat not available" >> "$LOG"

echo "=== Setup complete at $(date) ===" >> "$LOG"
echo "SETUP_DONE" >> "$LOG"
