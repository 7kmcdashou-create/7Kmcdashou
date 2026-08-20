#!/bin/bash
LOG=/tmp/hermes_setup.log
echo "=== $(date) attach start ===" > $LOG

export PATH="$HOME/.local/bin:$HOME/.hermes/bin:/usr/local/bin:$PATH"

# API config
export OPENAI_API_KEY="sk-Ui5cfObCJhJUbcsJSWJOUmZeabOIgPvm"
export OPENAI_API_BASE_URL="https://token.sensenova.cn/v1"
export OPENAI_BASE_URL="https://token.sensenova.cn/v1"

# Step 1: Write Hermes config
HERMES_DIR="$HOME/.hermes"
mkdir -p "$HERMES_DIR"

cat > "$HERMES_DIR/.env" << 'ENVEOF'
OPENAI_API_KEY=sk-Ui5cfObCJhJUbcsJSWJOUmZeabOIgPvm
ENVEOF
chmod 600 "$HERMES_DIR/.env"

cat > "$HERMES_DIR/config.yaml" << 'CFGEOF'
model:
  provider: custom
  base_url: https://token.sensenova.cn/v1
  default_model: sensenova-6.7-flash-lite
CFGEOF
echo "Config written" >> $LOG

# Step 2: Install hermes if needed
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

# Step 3: Kill existing
pkill -f "hermes dashboard" 2>/dev/null
pkill -f "hermes-web-ui" 2>/dev/null
pkill -f "open-webui" 2>/dev/null
sleep 2

# Step 4: Start Hermes dashboard on 9119
cd /tmp
nohup hermes dashboard --host 0.0.0.0 --no-open >> $LOG 2>&1 &
echo "Dashboard PID: $!" >> $LOG
sleep 15

# Step 5: Install and start hermes-web-ui (Open WebUI)
npm install -g hermes-web-ui >> $LOG 2>&1
# KEY FIX: pass API env vars so Open WebUI can connect to SenseTime
OPENAI_API_KEY="$OPENAI_API_KEY" OPENAI_API_BASE_URL="$OPENAI_API_BASE_URL" OPENAI_BASE_URL="$OPENAI_BASE_URL" nohup hermes-web-ui start 8648 --no-open >> $LOG 2>&1 &
echo "WebUI PID: $!" >> $LOG

sleep 10
ss -tlnp >> $LOG 2>&1
echo "=== $(date) done ===" >> $LOG
