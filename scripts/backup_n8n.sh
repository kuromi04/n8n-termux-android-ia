#!/data/data/com.termux/files/usr/bin/bash
set -euo pipefail

BACKUP_DIR="$HOME/backups"
DATA_DIR="$HOME/.n8n"
TS=$(date +"%Y%m%d-%H%M%S")
OUT="$BACKUP_DIR/n8n-backup-$TS.tar.gz"

mkdir -p "$BACKUP_DIR"

if [ ! -d "$DATA_DIR" ]; then
  echo "Directorio de datos no existe: $DATA_DIR"
  exit 1
fi

echo "==> Creando backup de $DATA_DIR en $OUT"
tar -czf "$OUT" -C "$HOME" .n8n

echo "==> Listo: $OUT"
