# n8n en Termux (Android) con IA — GRATIS, sin VPS, sin membresías

Automatiza con **n8n** directamente en tu **Android** usando **Termux** y **PM2**. 
Corre *local*, **gratis**, y evita pagar VPS o membresías de plataformas.

> ⚡️ Nota: Este repo acompaña un video corto de YouTube/TikTok/Shorts. Según el autor, es la **primera** instalación pública de n8n en Android vía Termux.

## 🚀 Qué obtienes
- **Scripts reproducibles** para instalación y arranque con PM2
- Guión del video + subtítulos `.srt`
- Instrucciones de seguridad y persistencia
- Archivo `.gitignore` y licencia MIT

---

## 📋 Requisitos
- Android 8+ (recomendado 10+)
- [Termux](https://termux.dev) (desde F-Droid o su repo oficial)
- Al menos **3 GB** de espacio libre
- Red local para acceder a n8n desde otro dispositivo (opcional)

---

## 🧰 Instalación rápida (copiar/pegar en Termux)

### 1) Clonar y entrar al proyecto (opcional)
```bash
pkg update -y && pkg upgrade -y
pkg install -y git
git clone https://github.com/tu-usuario/n8n-termux-android-ia.git
cd n8n-termux-android-ia
```

### 2) Ejecutar instalador
```bash
chmod +x scripts/install_n8n_termux.sh
./scripts/install_n8n_termux.sh
```

> El script aplica las mismas órdenes que en el video, incluyendo la solución NDK y SQLite.

### 3) Iniciar n8n con PM2
```bash
chmod +x scripts/start_n8n_pm2.sh
./scripts/start_n8n_pm2.sh
```

### 4) Autoinicio al abrir Termux
El instalador ya agrega una línea a `~/.bashrc` para **resucitar** procesos PM2. Si quieres revisarlo:
```bash
tail -n 5 ~/.bashrc
```

### 5) Acceder desde el navegador
Busca tu IP local y abre `http://IP:5678` en el navegador (del móvil u otro dispositivo en la misma red):
```bash
ifconfig
```

---

## 🛡️ Seguridad mínima recomendada
- Configura **credenciales** vía variables de entorno (no subas `.env` con datos reales).
- Si expones el puerto 5678 fuera de tu red local, usa **proxy** con autenticación (por ejemplo, Caddy/Traefik/Nginx en el móvil o en el router).
- Considera **túneles temporales** (ngrok/cloudflared) para pruebas, no para producción.

---

## 🔧 Variables de entorno útiles (opcional)
Crea `~/.n8n/.env` (y carga con `export $(grep -v '^#' ~/.n8n/.env | xargs)` antes de iniciar):
```ini
# Puerto donde escuchará n8n
N8N_PORT=5678

# Usuario/contraseña inicial (solo si usas basic auth en un reverse proxy)
BASIC_AUTH_USER=admin
BASIC_AUTH_PASSWORD=cambia_esto

# Directorio de datos
N8N_USER_FOLDER=$HOME/.n8n

# Producción / desarrollo
NODE_ENV=production
```

---

## 🧪 Verificación rápida
```bash
pm2 list
pm2 logs n8n --lines 50
curl -I http://127.0.0.1:5678
```

---

## 🧯 Solución de problemas
- **Error de compilación**: Repite `pkg install -y ndk-sysroot` y asegúrate de tener `clang`, `make` y `python` instalados.
- **SQLite no encontrado**: Verifica la ruta `--sqlite=/data/data/com.termux/files/usr/bin/sqlite3`.
- **PM2 no resucita**: Asegúrate que `~/.bashrc` contenga `pm2 resurrect` (sin comillas) y que ejecutaste `pm2 save`.
- **No abre en el navegador**: Comprueba IP con `ifconfig`, firewall del router y que el puerto `5678` esté accesible en LAN.

---

## 🧾 Créditos
- Autor: @tiendastelegram
- Inspirado por la comunidad n8n y Termux

## 📄 Licencia
[MIT](LICENSE)


---

## 💾 Copias de seguridad

Los datos de n8n viven en `$HOME/.n8n`. Usa los scripts incluidos:

**Crear backup (archivo `.tar.gz` con timestamp en `~/backups/`):**
```bash
./scripts/backup_n8n.sh
```

**Restaurar desde un backup:**
```bash
./scripts/restore_n8n.sh ~/backups/n8n-backup-YYYYmmdd-HHMMSS.tar.gz
```

> Consejos PM2:
```bash
pm2 list
pm2 logs n8n --lines 50
pm2 save && pm2 resurrect
```
