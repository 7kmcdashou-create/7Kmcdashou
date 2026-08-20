#!/bin/bash
LOG=/tmp/hermes_setup.log
echo "=== $(date) attach start ===" > $LOG

# Set API key for SenseTime
export OPENAI_API_KEY="sk-Ui5cfObCJhJUbcsJSWJOUmZeabOIgPvm"
export OPENAI_BASE_URL="https://api.sensenova.cn/compatible-mode/v2"

export PATH="$HOME/.local/bin:$HOME/.hermes/bin:/usr/local/bin:$PATH"

# Write hermes config
HERMES_DIR="$HOME/.hermes"
mkdir -p "$HERMES_DIR"

# Install Hermes if needed
if ! command -v hermes &>/dev/null; then
  echo "Installing hermes..." >> $LOG
  curl -fsSL https://raw.githubusercontent.com/NousResearch/hermes-agent/main/scripts/install.sh > /tmp/hi.sh 2>>$LOG
  if [ -f /tmp/hi.sh ]; then
    (bash /tmp/hi.sh --no-venv --skip-setup </dev/null >> $LOG 2>&1) || echo "Installer issues" >> $LOG
  fi
  export PATH="$HOME/.local/bin:$HOME/.hermes/bin:$PATH"
fi

which hermes >> $LOG 2>&1
hermes --version >> $LOG 2>&1

# Configure model via hermes config
if command -v hermes &>/dev/null; then
  echo "Configuring model..." >> $LOG
  hermes config set model.provider openai-compatible >> $LOG 2>&1 || true
  hermes config set model.api_key "$OPENAI_API_KEY" >> $LOG 2>&1 || true
  hermes config set model.base_url "$OPENAI_BASE_URL" >> $LOG 2>&1 || true
  hermes config set model.default_model "sensenova-nova-6.7-flash-lite" >> $LOG 2>&1 || true
fi

# Kill any existing hermes processes
pkill -f "hermes dashboard" 2>/dev/null || true
pkill -f "hermes-web-ui" 2>/dev/null || true
sleep 2

# Start dashboard
echo "Starting dashboard..." >> $LOG
cd /tmp
OPENAI_API_KEY="$OPENAI_API_KEY" OPENAI_BASE_URL="$OPENAI_BASE_URL" nohup hermes dashboard --host 0.0.0.0 --no-open >> $LOG 2>&1 &
echo "Dashboard PID: $!" >> $LOG
sleep 15

# Install web UI
npm install -g hermes-web-ui >> $LOG 2>&1 || true
OPENAI_API_KEY="$OPENAI_API_KEY" OPENAI_BASE_URL="$OPENAI_BASE_URL" nohup hermes-web-ui start 8648 --no-open >> $LOG 2>&1 &
echo "WebUI PID: $!" >> $LOG

sleep 10
ss -tlnp >> $LOG 2>&1
echo "=== $(date) attach done ===" >> $LOG
