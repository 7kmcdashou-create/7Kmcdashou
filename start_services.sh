#!/bin/bash
LOG=/tmp/hermes_setup.log
echo "=== $(date) Setup started ===" > $LOG
echo "Waiting for Docker..." >> $LOG
i=0; while [ $i -lt 120 ]; do docker info >/dev/null 2>&1 && echo "Docker ready $((i*3))s" >> $LOG && break; i=$((i+1)); sleep 3; done
docker info >/dev/null 2>&1 || { echo "Docker fail" >> $LOG; exit 0; }
cd /workspaces/7Kmcdashou
echo "Starting container..." >> $LOG
docker compose up -d >> $LOG 2>&1
sleep 15
docker ps -a >> $LOG 2>&1
echo "Installing hermes-web-ui..." >> $LOG
npm install -g hermes-web-ui >> $LOG 2>&1
echo "Starting hermes-web-ui..." >> $LOG
nohup hermes-web-ui start 8648 --no-open >> $LOG 2>&1 &
sleep 5
ss -tlnp >> $LOG 2>&1
echo "=== $(date) Done ===" >> $LOG
