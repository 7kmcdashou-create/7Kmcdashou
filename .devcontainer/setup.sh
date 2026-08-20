#!/bin/bash
LOG=/tmp/hermes_setup.log
echo "=== $(date) start ===" > $LOG

export PATH="$HOME/.local/bin:$HOME/.hermes/bin:/usr/local/bin:$PATH"
export OPENAI_API_KEY="sk-Ui5cfObCJhJUbcsJSWJOUmZeabOIgPvm"
export OPENAI_API_BASE_URL="https://token.sensenova.cn/v1"
export OPENAI_BASE_URL="https://token.sensenova.cn/v1"

# Write Hermes config
HERMES_DIR="$HOME/.hermes"
mkdir -p "$HERMES_DIR"
cat > "$HERMES_DIR/.env" << 'ENVEOF'
OPENAI_API_KEY=sk-Ui5cfObCJhJUbcsJSWJOUmZeabOIgPvm
ENVEOF
cat > "$HERMES_DIR/config.yaml" << 'CFGEOF'
model:
  provider: custom
  base_url: https://token.sensenova.cn/v1
  default_model: sensenova-6.7-flash-lite
CFGEOF

# Install hermes if needed
if ! command -v hermes &>/dev/null; then
  echo "Installing hermes..." >> $LOG
  curl -fsSL https://raw.githubusercontent.com/NousResearch/hermes-agent/main/scripts/install.sh > /tmp/hi.sh 2>>$LOG
  [ -f /tmp/hi.sh ] && (bash /tmp/hi.sh --no-venv --skip-setup </dev/null >> $LOG 2>&1)
  export PATH="$HOME/.local/bin:$HOME/.hermes/bin:$PATH"
fi
which hermes >> $LOG 2>&1

# Kill everything
pkill -f "hermes dashboard" 2>/dev/null
pkill -f "hermes-web-ui" 2>/dev/null
pkill -f "open-webui" 2>/dev/null
sleep 2

# Start dashboard
cd /tmp
nohup hermes dashboard --host 0.0.0.0 --no-open >> $LOG 2>&1 &
sleep 15

# CRITICAL: delete Open WebUI data so env vars take effect on fresh start
rm -rf "$HOME/.open-webui" 2>/dev/null
rm -rf "$HOME/.hermes-web-ui" 2>/dev/null
npm install -g hermes-web-ui >> $LOG 2>&1

# Start WebUI with env vars (first-launch auto-config)
OPENAI_API_KEY="$OPENAI_API_KEY" \
OPENAI_API_BASE_URL="$OPENAI_API_BASE_URL" \
OPENAI_BASE_URL="$OPENAI_BASE_URL" \
nohup hermes-web-ui start 8648 --no-open >> $LOG 2>&1 &

sleep 10
ss -tlnp >> $LOG 2>&1
echo "=== $(date) done ===" >> $LOG
