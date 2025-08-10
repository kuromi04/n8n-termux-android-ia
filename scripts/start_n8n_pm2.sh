#!/data/data/com.termux/files/usr/bin/bash
set -euo pipefail

echo "==> Arrancando n8n con PM2"
pm2 start n8n || true
pm2 save
pm2 status
