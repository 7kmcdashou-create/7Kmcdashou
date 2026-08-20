#!/bin/bash
LOG=/tmp/hermes_setup.log
echo "start $(date)" > $LOG

# Use official installer in non-interactive mode
curl -fsSL https://raw.githubusercontent.com/NousResearch/hermes-agent/main/scripts/install.sh > /tmp/hermes_install.sh 2>>$LOG
if [ -f /tmp/hermes_install.sh ]; then
  # Run with --no-venv and non-interactive flags
  # The installer has set -e, so we run it in a subshell and capture result
  bash /tmp/hermes_install.sh --no-venv --skip-setup >> $LOG 2>&1
  INSTALLED=$?
  echo "Installer exit: $INSTALLED" >> $LOG
else
  echo "Failed to download installer" >> $LOG
fi

# Reload PATH
export PATH="$HOME/.local/bin:$HOME/.hermes/bin:/usr/local/bin:$PATH"
echo "PATH: $PATH" >> $LOG
which hermes >> $LOG 2>&1
hermes --version >> $LOG 2>&1

# Try to start dashboard
hermes dashboard --host 0.0.0.0 --no-open >> $LOG 2>&1 &
echo "Dashboard PID: $!" >> $LOG
sleep 10

# Also try hermes-web-ui
npm install -g hermes-web-ui >> $LOG 2>&1
hermes-web-ui start 8648 --no-open >> $LOG 2>&1 &
echo "WebUI PID: $!" >> $LOG

sleep 5
ss -tlnp >> $LOG 2>&1
echo "done $(date)" >> $LOG
