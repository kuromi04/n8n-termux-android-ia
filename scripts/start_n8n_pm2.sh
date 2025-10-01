#!/data/data/com.termux/files/usr/bin/bash
set -euo pipefail

echo "==> Arrancando n8n con PM2"
pm2 start n8n || true
pm2 save
pm2 status

echo "==> n8n está corriendo en segundo plano."
echo "==> Presiona 'o' para abrir en el navegador o cualquier otra tecla para salir."

read -n 1 -s key

if [[ $key == "o" ]]; then
  echo "==> Abriendo n8n en el navegador..."
  termux-open-url http://localhost:5678
fi

echo "==> Hecho."⏎
