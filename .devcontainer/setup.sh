#!/bin/bash
LOG=/tmp/hermes_setup.log
echo "=== $(date) attach start ===" > $LOG

export PATH="$HOME/.local/bin:$HOME/.hermes/bin:/usr/local/bin:$PATH"

# Step 1: Write config files DIRECTLY (most reliable)
HERMES_DIR="$HOME/.hermes"
mkdir -p "$HERMES_DIR"

# Write .env with API key
cat > "$HERMES_DIR/.env" << 'ENVEOF'
OPENAI_API_KEY=sk-Ui5cfObCJhJUbcsJSWJOUmZeabOIgPvm
ENVEOF
chmod 600 "$HERMES_DIR/.env"
echo ".env written" >> $LOG

# Write config.yaml with custom provider
cat > "$HERMES_DIR/config.yaml" << 'CFGEOF'
model:
  provider: custom
  base_url: https://token.sensenova.cn/v1
  default_model: sensenova-6.7-flash-lite
CFGEOF
echo "config.yaml written" >> $LOG

# Step 2: Install Hermes if not present
if ! command -v hermes &>/dev/null; then
  echo "Installing hermes..." >> $LOG
  curl -fsSL https://raw.githubusercontent.com/NousResearch/hermes-agent/main/scripts/install.sh > /tmp/hi.sh 2>>$LOG
  if [ -f /tmp/hi.sh ]; then
    (bash /tmp/hi.sh --no-venv --skip-setup </dev/null >> $LOG 2>&1)
    export PATH="$HOME/.local/bin:$HOME/.hermes/bin:$PATH"
  fi
fi

which hermes >> $LOG 2>&1
hermes --version >> $LOG 2>&1

# Step 3: Kill existing processes
pkill -f "hermes dashboard" 2>/dev/null
pkill -f "hermes-web-ui" 2>/dev/null
sleep 2

# Step 4: Start dashboard
echo "Starting dashboard..." >> $LOG
cd /tmp
nohup hermes dashboard --host 0.0.0.0 --no-open >> $LOG 2>&1 &
echo "Dashboard PID: $!" >> $LOG
sleep 15

# Step 5: Start web UI
npm install -g hermes-web-ui >> $LOG 2>&1
nohup hermes-web-ui start 8648 --no-open >> $LOG 2>&1 &
echo "WebUI PID: $!" >> $LOG

sleep 10
ss -tlnp >> $LOG 2>&1
echo "=== $(date) done ===" >> $LOG
