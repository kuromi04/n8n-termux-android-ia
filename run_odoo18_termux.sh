#!/data/data/com.termux/files/usr/bin/bash
set -euo pipefail
# Arranca Odoo 18 dentro de Ubuntu-proot en el puerto 8069 (o usa PORT=XXXX)
PORT="${PORT:-8069}"
echo "==> Iniciando Odoo 18 en http://127.0.0.1:${PORT}"
proot-distro login ubuntu -- bash -lc "PORT=${PORT} /root/odoo18_run.sh"
