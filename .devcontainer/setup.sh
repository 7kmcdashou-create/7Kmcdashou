#!/bin/bash
LOG=/tmp/hermes_setup.log
echo "=== $(date) start ===" > $LOG

export PATH="$HOME/.local/bin:/usr/local/bin:$PATH"

# Step 1: Install hermes-agent
pip install --user hermes-agent >> $LOG 2>&1
export PATH="$HOME/.local/bin:$PATH"

echo "hermes location:" >> $LOG
which hermes >> $LOG 2>&1
hermes --version >> $LOG 2>&1

# Step 2: Start hermes dashboard
cd /tmp
hermes dashboard --host 0.0.0.0 --no-open >> $LOG 2>&1 &
echo "hermes started pid=$!" >> $LOG

# Step 3: Wait for dashboard
sleep 15
curl -s http://localhost:9119 > /dev/null 2>&1 && echo "port 9119 OK" >> $LOG || echo "port 9119 FAIL" >> $LOG

# Step 4: Install hermes-web-ui
npm install -g hermes-web-ui >> $LOG 2>&1
hermes-web-ui start 8648 --no-open >> $LOG 2>&1 &
echo "webui started pid=$!" >> $LOG

sleep 10
curl -s http://localhost:8648 > /dev/null 2>&1 && echo "port 8648 OK" >> $LOG || echo "port 8648 FAIL" >> $LOG

ss -tlnp >> $LOG 2>&1
echo "=== $(date) done ===" >> $LOG
