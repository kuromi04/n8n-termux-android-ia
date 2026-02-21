# 🚀 n8n en Termux (Android) v2.1 - Instalación con UN SOLO COMANDO
[![Shell](https://img.shields.io/badge/Shell-Bash-4EAA25?logo=gnu-bash&logoColor=white)](https://www.gnu.org/software/bash/)
[![Node.js](https://img.shields.io/badge/Node.js-LTS-339933?logo=node.js&logoColor=white)](https://nodejs.org/)
[![n8n](https://img.shields.io/badge/n8n-latest-FF6D5A?logo=n8n&logoColor=white)](https://n8n.io/)
[![PM2](https://img.shields.io/badge/PM2-Process%20Manager-2B037A)](https://pm2.keymetrics.io/)
[![Version](https://img.shields.io/badge/version-2.1-blue)](https://github.com/kuromi04/n8n-termux-android-ia/releases)
[![License](https://img.shields.io/badge/License-MIT-blue)](LICENSE)

> ⚡ Instalación completa con un solo comando. Soporte para npm y pnpm. Alias integrados. Scripts corregidos para funcionar en Termux moderno.

Automatiza con **n8n** directamente en tu **Android** usando **Termux** y **PM2**.
Corre local, **gratis**, sin pagar VPS ni suscripciones.

---

## 📹 Video Tutorial

YouTube: https://youtube.com/shorts/tXAiWUwH88A?si=xkMO0f-VUkp9jR1Q

---

## ✨ ¿Qué incluye v2.1?

- ✅ **Instalación con UN SOLO COMANDO**
- ✅ **Soporte para npm y pnpm** (tú eliges)
- ✅ **Alias integrados** — escribe `n8n` y listo
- ✅ **Siempre instala la última versión** de n8n
- ✅ **Sistema de backup** integrado
- ✅ **Gestor interactivo** (`n8n-manager`)
- ✅ **Auto-inicio con PM2** al abrir Termux
- ✅ **Compatibilidad corregida** con Termux moderno (sin `ifconfig`, sin `free`, sin `ps a`)

---

## 📋 Requisitos

- Android 8+ (recomendado Android 10+)
- Termux instalado correctamente → [ver instrucciones abajo](#-instalación-de-termux)
- Al menos **2 GB de RAM** libre
- Al menos **1 GB de espacio** libre

---

## 📲 Instalación de Termux

> ⚠️ **MUY IMPORTANTE**: NO instales Termux desde Google Play Store. Está desactualizado y dará errores.

**Opción 1 — GitHub oficial (recomendado):**
1. Descarga el `.apk` desde: https://github.com/termux/termux-app/releases
2. Instálalo (activa "orígenes desconocidos" si es necesario)

**Opción 2 — F-Droid:**
1. Instala F-Droid desde: https://f-droid.org/
2. Busca "Termux" y descarga desde allí

Verifica que funciona con:
```bash
termux-info
```

---

## 🎯 Instalación

### Método 1 — Un solo comando (recomendado)

```bash
curl -fsSL https://raw.githubusercontent.com/kuromi04/n8n-termux-android-ia/main/scripts/install.sh | bash
```

### Método 2 — Clonar el repositorio

```bash
pkg update -y && pkg upgrade -y
pkg install -y git
git clone https://github.com/kuromi04/n8n-termux-android-ia.git
cd n8n-termux-android-ia
chmod +x scripts/install.sh
./scripts/install.sh
```

El instalador hace todo automáticamente:
- Actualiza Termux y paquetes
- Instala dependencias de compilación
- Detecta o instala npm / pnpm
- Instala PM2 y n8n (última versión)
- Configura variables de entorno y alias
- Crea scripts de utilidad

---

## 🚀 Primeros pasos tras instalar

**1. Aplica los alias (solo la primera vez):**
```bash
source ~/.bashrc
```

**2. Inicia n8n:**
```bash
n8n
```

**3. Abre en el navegador:**

Desde el mismo dispositivo:
```
http://localhost:5678
```

Desde otro dispositivo en la misma red WiFi — primero obtén tu IP:
```bash
ip route get 1.1.1.1
```
Luego abre: `http://TU_IP:5678`

---

## ⌨️ Comandos disponibles

```bash
n8n              # Iniciar n8n
n8n-start        # Iniciar n8n (igual que el anterior)
n8n-stop         # Detener n8n
n8n-restart      # Reiniciar n8n
n8n-status       # Ver estado del proceso
n8n-logs         # Ver logs en tiempo real
n8n-update       # Actualizar a la última versión
n8n-backup       # Crear backup completo
n8n-manager      # Abrir el gestor visual interactivo
```

---

## ⚙️ Configuración

El instalador crea automáticamente `~/.n8n/.env`. Para editarlo:

```bash
nano ~/.n8n/.env
```

Variables principales:

```env
# Puerto de acceso (por defecto: 5678)
N8N_PORT=5678

# Escuchar en toda la red (necesario para acceder desde otro dispositivo)
N8N_HOST=0.0.0.0

# Base de datos SQLite (recomendada para móvil)
DB_TYPE=sqlite
DB_SQLITE_DATABASE=/data/data/com.termux/files/home/.n8n/database.sqlite

# Autenticación (desactivada por defecto, actívala si expones n8n)
N8N_BASIC_AUTH_ACTIVE=false
N8N_BASIC_AUTH_USER=admin
N8N_BASIC_AUTH_PASSWORD=cambia_esto_ahora

# Nivel de logs
N8N_LOG_LEVEL=info
```

Después de editar, reinicia:
```bash
n8n-restart
```

---

## 💾 Backups

**Crear backup manual:**
```bash
n8n-backup
```

Los backups se guardan en `~/backups/` con timestamp (ej: `n8n-backup-20240315-143022.tar.gz`).

**Restaurar desde backup:**
```bash
~/.n8n/restore.sh ~/backups/n8n-backup-FECHA.tar.gz
```

**Backup automático diario (opcional):**
```bash
pkg install cronie termux-services
sv-enable crond
crontab -e
# Agregar esta línea:
0 3 * * * ~/.n8n/backup.sh
```

---

## 🔄 Actualización

```bash
n8n-update
```

O manualmente:
```bash
# Con npm:
npm install -g n8n@latest && pm2 restart n8n

# Con pnpm:
pnpm install -g n8n@latest && pm2 restart n8n
```

---

## 🛡️ Seguridad

**Activar autenticación** (muy recomendado si usas n8n en red local):

Edita `~/.n8n/.env`:
```env
N8N_BASIC_AUTH_ACTIVE=true
N8N_BASIC_AUTH_USER=tu_usuario
N8N_BASIC_AUTH_PASSWORD=contraseña_segura
```
Luego: `n8n-restart`

**No expongas el puerto 5678 directamente a internet.** Si necesitas acceso externo, usa un túnel seguro:
```bash
# Con cloudflared (recomendado):
pkg install cloudflared
cloudflared tunnel --url http://localhost:5678

# Con ngrok:
# Descarga desde ngrok.com/download → versión Linux ARM
```

---

## 🧯 Solución de Problemas

### n8n no inicia
```bash
n8n-logs          # Ver qué error aparece
pm2 list          # Ver estado de todos los procesos
pm2 kill          # Matar PM2 completamente
pm2 resurrect     # Restaurar procesos guardados
```

### Error durante la instalación (falló compilación)
```bash
pkg install -y ndk-sysroot clang make binutils pkg-config
# Luego volver a ejecutar el instalador
```

### No puedo acceder desde otro dispositivo
```bash
# 1. Verifica tu IP local
ip route get 1.1.1.1

# 2. Verifica que n8n escucha en 0.0.0.0
grep N8N_HOST ~/.n8n/.env
# Debe mostrar: N8N_HOST=0.0.0.0

# 3. Asegúrate de estar en la misma red WiFi que el otro dispositivo
```

### PM2 no recuerda los procesos al reiniciar Termux
```bash
pm2 save          # Guardar estado actual
# El .bashrc ya incluye: pm2 resurrect (se ejecuta al abrir Termux)
```

### Alias no funcionan tras reinstalar
```bash
source ~/.bashrc
```

---

## 📁 Estructura de archivos

```
~/.n8n/
├── .env                 # Configuración principal
├── database.sqlite      # Base de datos
├── logs/                # Logs de n8n
├── start-n8n.sh         # Script de inicio (usado por el alias n8n)
├── backup.sh            # Script de backup
├── restore.sh           # Script de restauración
├── update.sh            # Script de actualización
└── n8n-manager.sh       # Gestor visual interactivo

~/backups/
└── n8n-backup-*.tar.gz  # Backups con timestamp
```

---

## 🔧 Comandos PM2 de referencia

```bash
pm2 list                  # Ver todos los procesos
pm2 show n8n              # Detalles de n8n
pm2 logs n8n              # Ver logs
pm2 logs n8n --lines 100  # Ver últimas 100 líneas
pm2 restart n8n           # Reiniciar
pm2 stop n8n              # Detener
pm2 delete n8n            # Eliminar de PM2
pm2 save                  # Guardar estado
pm2 resurrect             # Restaurar procesos guardados
pm2 monit                 # Monitor en tiempo real
pm2 flush                 # Limpiar logs de PM2
```

---

## 🤖 Casos de uso con IA

- Bots de Telegram/WhatsApp con respuestas de IA (OpenAI, Claude, Gemini)
- Automatización de Google Sheets con análisis inteligente
- Web scraping y resumen automático con IA
- Notificaciones inteligentes con filtrado por IA
- Generación de imágenes con DALL-E / Stable Diffusion
- Asistentes virtuales personalizados
- Respuesta automática de emails con contexto
- Pipelines de procesamiento de documentos

Todo esto **sin pagar VPS**, directamente desde tu Android.

---

## 🤝 Contribuir

1. Fork el repositorio
2. Crea una rama: `git checkout -b feature/mejora`
3. Commit: `git commit -am 'Descripción del cambio'`
4. Push: `git push origin feature/mejora`
5. Abre un Pull Request

---

## 📄 Licencia

[MIT](LICENSE) — Usa, modifica y distribuye libremente.

---

## 🧾 Créditos

- **Autor**: [@Maka0024](https://t.me/tiendastelegram)
- **Inspirado por**: Comunidad n8n, Termux e IvanByCinderella
- **Repo**: https://github.com/kuromi04/n8n-termux-android-ia

---

## 📞 Soporte

- 🐛 [Abrir Issue](https://github.com/kuromi04/n8n-termux-android-ia/issues)
- 💬 [Telegram](https://t.me/tiendastelegram)

---

## ⭐ ¿Te fue útil?

Dale una estrella en GitHub y compártelo con otros. 🙌

![GitHub stars](https://img.shields.io/github/stars/kuromi04/n8n-termux-android-ia?style=social)
![GitHub forks](https://img.shields.io/github/forks/kuromi04/n8n-termux-android-ia?style=social)

---

**¡Disfruta automatizando desde tu Android! 🚀📱**
