#!/data/data/com.termux/files/usr/bin/bash
set -euo pipefail

echo "==> Actualizando Termux paquetes..."
pkg update -y
pkg install -y proot-distro curl wget git

echo "==> Instalando Ubuntu dentro de Termux (proot-distro) si no existe..."
if ! proot-distro list | awk '{print $1}' | grep -qx ubuntu; then
  proot-distro install ubuntu
fi

echo "==> Preparando Ubuntu: Odoo 18 + PostgreSQL"
proot-distro login ubuntu -- bash -lc '
  set -euo pipefail
  export DEBIAN_FRONTEND=noninteractive

  echo "-> apt update"
  apt-get update

  echo "-> Dependencias base"
  apt-get install -y gnupg ca-certificates lsb-release

  echo "-> Agregando repo oficial de Odoo 18"
  install -d -m 0755 /usr/share/keyrings
  curl -fsSL https://nightly.odoo.com/odoo.key | gpg --dearmor -o /usr/share/keyrings/odoo-archive-keyring.gpg
  echo "deb [signed-by=/usr/share/keyrings/odoo-archive-keyring.gpg] https://nightly.odoo.com/18.0/nightly/deb/ ./" > /etc/apt/sources.list.d/odoo.list

  echo "-> Instalando PostgreSQL y Odoo"
  apt-get update
  apt-get install -y postgresql postgresql-contrib odoo

  echo "-> Arrancando PostgreSQL (sin systemd)"
  if command -v pg_ctlcluster >/dev/null 2>&1; then
    pg_lsclusters --no-header | awk "{print \$1, \$2}" | while read v n; do pg_ctlcluster "$v" "$n" start; done
  fi

  echo "-> Creando rol superusuario para Odoo (si no existe)"
  su - postgres -c "createuser -s odoo" || true

  echo "-> Creando script de arranque rápido: /root/odoo18_run.sh"
  cat >/root/odoo18_run.sh <<\"EOF\"
#!/bin/bash
set -euo pipefail
if command -v pg_ctlcluster >/dev/null 2>&1; then
  pg_lsclusters --no-header | awk '{print $1, $2}' | while read v n; do pg_ctlcluster "$v" "$n" start; done
fi
exec odoo --db_host=127.0.0.1 --http-port=${PORT:-8069} --log-level=info
EOF
  chmod +x /root/odoo18_run.sh

  echo "==> Instalación dentro de Ubuntu completada."
'

echo "==> Listo. Para arrancar Odoo luego, crea (si no lo tienes) y usa run_odoo18_termux.sh"
