#!/bin/bash
LOG=/tmp/hermes_setup.log
echo "=== $(date) attach start ===" > $LOG

export PATH="$HOME/.local/bin:$HOME/.hermes/bin:/usr/local/bin:$PATH"

# Install Hermes via official installer
if ! command -v hermes &>/dev/null; then
  echo "Downloading installer..." >> $LOG
  curl -fsSL https://raw.githubusercontent.com/NousResearch/hermes-agent/main/scripts/install.sh > /tmp/hi.sh 2>>$LOG
  if [ -f /tmp/hi.sh ]; then
    echo "Running installer with --no-venv --skip-setup..." >> $LOG
    # The installer has set -e, wrap in subshell to prevent our script dying
    (bash /tmp/hi.sh --no-venv --skip-setup </dev/null >> $LOG 2>&1) || echo "Installer had issues" >> $LOG
  fi
  export PATH="$HOME/.local/bin:$HOME/.hermes/bin:$PATH"
fi

which hermes >> $LOG 2>&1
hermes --version >> $LOG 2>&1

# Start dashboard
echo "Starting dashboard..." >> $LOG
cd /tmp
nohup hermes dashboard --host 0.0.0.0 --no-open >> $LOG 2>&1 &
echo "Dashboard PID: $!" >> $LOG
sleep 15

# Install web UI
npm install -g hermes-web-ui >> $LOG 2>&1 || true
nohup hermes-web-ui start 8648 --no-open >> $LOG 2>&1 &
echo "WebUI PID: $!" >> $LOG

sleep 10
ss -tlnp >> $LOG 2>&1
echo "=== $(date) attach done ===" >> $LOG
