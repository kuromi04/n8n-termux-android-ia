#!/data/data/com.termux/files/usr/bin/bash
set -euo pipefail

if [ $# -lt 1 ]; then
  echo "Uso: $0 <ruta_al_backup.tar.gz>"
  exit 1
fi

ARCHIVE="$1"
DATA_DIR="$HOME/.n8n"

if [ ! -f "$ARCHIVE" ]; then
  echo "Archivo no encontrado: $ARCHIVE"
  exit 1
fi

echo "==> Deteniendo n8n (si corre con PM2)"
pm2 stop n8n || true

echo "==> Restaurando datos en $DATA_DIR"
mkdir -p "$DATA_DIR"
# Extrae en $HOME para respetar estructura .n8n
tar -xzf "$ARCHIVE" -C "$HOME"

echo "==> Ajustando permisos"
chmod -R 700 "$DATA_DIR" || true

echo "==> Arrancando n8n de nuevo"
pm2 start n8n || true
pm2 save || true
pm2 status
