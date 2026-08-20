#!/bin/bash
LOG=/tmp/hermes_setup.log
exec > >(tee -a "$LOG") 2>&1
echo "=== $(date) Setup started ==="

# Add pipx to PATH
export PATH="$HOME/.local/bin:$PATH"

# Install pipx if needed
if ! command -v pipx &>/dev/null; then
  echo "Installing pipx..."
  python3 -m pip install --user pipx 2>&1 || true
  python3 -m pipx ensurepath 2>&1 || true
  export PATH="$HOME/.local/bin:$PATH"
fi

# Install hermes-agent via pipx
if ! command -v hermes &>/dev/null; then
  echo "Installing hermes-agent via pipx..."
  pipx install hermes-agent 2>&1 || {
    echo "pipx failed, trying pip direct..."
    pip install --user hermes-agent 2>&1 || true
  }
fi

echo "Hermes version:" $(hermes --version 2>&1 || echo "not found")

# Start Hermes dashboard on port 9119 in background
echo "Starting Hermes dashboard..."
nohup hermes dashboard --host 0.0.0.0 --port 9119 --no-open > /tmp/hermes_dashboard.log 2>&1 &
HERMES_PID=$!
echo "Hermes PID: $HERMES_PID"

# Wait for Hermes to start
echo "Waiting for Hermes dashboard..."
for i in $(seq 1 30); do
  if curl -s http://localhost:9119 >/dev/null 2>&1; then
    echo "Hermes dashboard ready after ${i}x2s"
    break
  fi
  sleep 2
done

# Install hermes-web-ui via npm
echo "Installing hermes-web-ui..."
npm install -g hermes-web-ui 2>&1 || true

# Start hermes-web-ui on port 8648
echo "Starting hermes-web-ui..."
nohup hermes-web-ui start 8648 --no-open > /tmp/hermes_webui.log 2>&1 &
WEBUI_PID=$!
echo "WebUI PID: $WEBUI_PID"

# Wait for WebUI
for i in $(seq 1 20); do
  if curl -s http://localhost:8648 >/dev/null 2>&1; then
    echo "hermes-web-ui ready after ${i}x2s"
    break
  fi
  sleep 2
done

# Final status
echo "=== Port check ==="
ss -tlnp 2>/dev/null || netstat -tlnp 2>/dev/null || echo "no port tool"
echo "=== $(date) Setup complete ==="
