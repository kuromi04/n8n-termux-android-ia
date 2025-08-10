#!/data/data/com.termux/files/usr/bin/bash
set -euo pipefail

# Simple backup/restore script for n8n workflows and data

DATA_DIR="$HOME/.n8n"
BACKUP_DIR="$HOME/n8n_backups"
DATE=$(date +%Y%m%d_%H%M%S)

usage() {
  echo "Usage: $0 backup|restore [backup_file]"
  exit 1
}

mkdir -p "$BACKUP_DIR"

case "${1:-}" in
  backup)
    BACKUP_FILE="$BACKUP_DIR/n8n_backup_$DATE.tar.gz"
    echo "==> Creating backup: $BACKUP_FILE"
    tar -czf "$BACKUP_FILE" -C "$DATA_DIR" .
    echo "Backup completed."
    ;;
  restore)
    if [ -z "${2:-}" ]; then
      echo "Error: Missing backup file for restore."
      usage
    fi
    BACKUP_FILE="$2"
    if [ ! -f "$BACKUP_FILE" ]; then
      echo "Error: File not found: $BACKUP_FILE"
      exit 1
    fi
    echo "==> Restoring from: $BACKUP_FILE"
    tar -xzf "$BACKUP_FILE" -C "$DATA_DIR"
    echo "Restore completed."
    ;;
  *)
    usage
    ;;
esac
