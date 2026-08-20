#!/bin/bash
set -e

echo "=== Hermes setup started at $(date) ==="

# Install hermes-agent
pip install hermes-agent

# Verify install
hermes --version

# Install cloudflared for public tunnel
if ! command -v cloudflared &>/dev/null; then
    curl -sL https://github.com/cloudflare/cloudflared/releases/latest/download/cloudflared-linux-amd64 -o /usr/local/bin/cloudflared
    chmod +x /usr/local/bin/cloudflared
    echo "cloudflared installed: $(cloudflared --version)"
fi

# Create config directory
mkdir -p ~/.hermes

# Write config.yaml
cat > ~/.hermes/config.yaml << 'HERMES_CFG'
model: sensenova/sensenova-6.7-flash-lite

providers:
  sensenova:
    name: SenseNova
    base_url: https://token.sensenova.cn/v1
    models:
      - sensenova-6.7-flash-lite

dashboard:
  basic_auth:
    username: admin
    password: hermes123456
  public_url: https://hermes.7kmcdashou.workers.dev
HERMES_CFG

# Write .env with API key
cat > ~/.hermes/.env << 'HERMES_ENV'
OPENAI_API_KEY=sk-Ui5cfObCJhJUbcsJSWJOUmZeabOIgPvm
HERMES_ENV

chmod 600 ~/.hermes/.env

echo "=== Hermes setup completed at $(date) ==="
