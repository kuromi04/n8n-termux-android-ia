# 🚀 n8n en Termux (Android) v2.0 - Instalación con UN SOLO COMANDO

[![Shell](https://img.shields.io/badge/Shell-Bash-4EAA25?logo=gnu-bash&logoColor=white)](https://www.gnu.org/software/bash/)
[![Node.js](https://img.shields.io/badge/Node.js-LTS-339933?logo=node.js&logoColor=white)](https://nodejs.org/)
[![n8n](https://img.shields.io/badge/n8n-2.0-FF6D5A?logo=n8n&logoColor=white)](https://n8n.io/)
[![PM2](https://img.shields.io/badge/PM2-Process%20Manager-2B037A)](https://pm2.keymetrics.io/)
[![License](https://img.shields.io/badge/License-MIT-blue)](LICENSE)

> ⚡ **NUEVO**: Instalación completa con un solo comando. Soporte para npm y pnpm. Alias integrados para facilidad de uso.

Automatiza con **n8n 2.0** directamente en tu **Android** usando **Termux** y **PM2**.
Corre *local*, **gratis**, y evita pagar VPS o membresías de plataformas.

---

## 📹 Video Tutorial

YouTube: https://youtube.com/shorts/tXAiWUwH88A?si=xkMO0f-VUkp9jR1Q

> 🎯 Primera instalación pública de n8n en Android vía Termux

---

## ✨ ¿Qué hay de nuevo en v2.0?

- ✅ **Instalación con UN SOLO COMANDO**
- ✅ **Soporte para npm Y pnpm** (tú eliges)
- ✅ **Alias integrados** - Escribe `n8n` y listo
- ✅ **Siempre instala la última versión** de n8n
- ✅ **Sistema de backup automatizado**
- ✅ **Scripts de utilidad incluidos**
- ✅ **Auto-inicio con PM2** al abrir Termux
- ✅ **Logs centralizados** para debugging

---

## 🎯 Instalación Ultra-Rápida (Un solo comando)

### Método 1: Instalación directa (Recomendado)

```bash
curl -fsSL https://raw.githubusercontent.com/kuromi04/n8n-termux-android-ia/main/install.sh | bash
```

### Método 2: Clonar repositorio

```bash
pkg update -y && pkg upgrade -y
pkg install -y git
git clone https://github.com/kuromi04/n8n-termux-android-ia.git
cd n8n-termux-android-ia
chmod +x install.sh
./install.sh
```

**Eso es todo.** El script hace todo automáticamente:
- ✓ Actualiza Termux
- ✓ Instala dependencias
- ✓ Detecta/instala npm o pnpm
- ✓ Instala PM2
- ✓ Instala n8n (última versión)
- ✓ Configura alias
- ✓ Crea scripts de utilidad

---

## 🚀 Uso después de instalar

### Aplicar cambios (solo la primera vez)

```bash
source ~/.bashrc
```

### Iniciar n8n

```bash
n8n
```

### Otros comandos disponibles

```bash
n8n-start      # Iniciar n8n
n8n-stop       # Detener n8n
n8n-restart    # Reiniciar n8n
n8n-status     # Ver estado
n8n-logs       # Ver logs en tiempo real
n8n-update     # Actualizar a última versión
n8n-backup     # Crear backup
```

### Acceder desde el navegador

1. Ejecuta `ifconfig` para obtener tu IP local
2. Abre en tu navegador: `http://TU_IP:5678`

**Ejemplo:**
```
http://192.168.1.100:5678
```

---

## 📋 Requisitos

- Android 8+ (recomendado Android 10+)
- Termux ([Instalar desde aquí](#-instalación-de-termux))
- Al menos **2 GB** de RAM libre
- Al menos **1 GB** de espacio libre
- Red local para acceder desde otro dispositivo (opcional)

---

## 📲 Instalación de Termux

> ⚠️ **MUY IMPORTANTE**: NO instales Termux desde Google Play Store. Está desactualizado.

### Opción 1: GitHub Oficial (Recomendado)

1. Descarga desde: https://github.com/termux/termux-app/releases
2. Busca la última versión estable (`.apk`)
3. Instala el APK (activa "orígenes desconocidos" si es necesario)

### Opción 2: F-Droid

1. Descarga F-Droid: https://f-droid.org/
2. Busca "Termux" en F-Droid
3. Instala desde allí

### Verificación

```bash
termux-info
```

Debe mostrar la versión instalada y arquitectura.

---

## ⚙️ Configuración Avanzada

### Variables de entorno

El instalador crea automáticamente `~/.n8n/.env` con configuración óptima. Puedes editarlo:

```bash
nano ~/.n8n/.env
```

**Variables importantes:**

```env
# Puerto (por defecto: 5678)
N8N_PORT=5678

# Host (0.0.0.0 permite acceso desde red local)
N8N_HOST=0.0.0.0

# Ubicación de datos
N8N_USER_FOLDER=/data/data/com.termux/files/home/.n8n

# Base de datos (SQLite por defecto)
DB_TYPE=sqlite
DB_SQLITE_DATABASE=/data/data/com.termux/files/home/.n8n/database.sqlite

# Seguridad (activar auth básico)
N8N_BASIC_AUTH_ACTIVE=true
N8N_BASIC_AUTH_USER=admin
N8N_BASIC_AUTH_PASSWORD=cambiar_esto

# Logs
N8N_LOG_LEVEL=info
N8N_LOG_LOCATION=/data/data/com.termux/files/home/.n8n/logs/
```

Después de editar, reinicia n8n:

```bash
n8n-restart
```

---

## 💾 Backups y Restauración

### Crear backup

```bash
n8n-backup
```

O manualmente:

```bash
~/. n8n/backup.sh
```

Los backups se guardan en `~/backups/` con timestamp.

### Restaurar desde backup

```bash
~/.n8n/restore.sh ~/backups/n8n-backup-20231219-153045.tar.gz
```

---

## 🔄 Actualización

### Actualizar n8n a la última versión

```bash
n8n-update
```

O manualmente:

```bash
npm install -g n8n@latest  # o pnpm install -g n8n@latest
pm2 restart n8n
```

---

## 🛡️ Seguridad Recomendada

### 1. Activar autenticación básica

Edita `~/.n8n/.env`:

```env
N8N_BASIC_AUTH_ACTIVE=true
N8N_BASIC_AUTH_USER=tu_usuario
N8N_BASIC_AUTH_PASSWORD=tu_contraseña_segura
```

### 2. No expongas el puerto 5678 a Internet

- Usa n8n solo en red local
- Si necesitas acceso externo, usa túneles seguros (ngrok, cloudflared)

### 3. Backups regulares

Configura un cron job (usando termux-services):

```bash
pkg install cronie termux-services
sv-enable crond

# Editar crontab
crontab -e

# Agregar backup diario a las 3 AM
0 3 * * * ~/.n8n/backup.sh
```

---

## 🧯 Solución de Problemas

### n8n no inicia

```bash
# Ver logs detallados
n8n-logs

# Verificar PM2
pm2 list

# Reiniciar PM2
pm2 kill
pm2 resurrect
```

### Error de compilación durante instalación

```bash
pkg install -y ndk-sysroot clang make binutils
```

### No puedo acceder desde otro dispositivo

1. Verifica tu IP:
   ```bash
   ifconfig
   ```

2. Asegúrate que estés en la misma red WiFi

3. Verifica el firewall de tu router

4. Confirma que n8n está escuchando en 0.0.0.0:
   ```bash
   grep N8N_HOST ~/.n8n/.env
   ```

### PM2 no resucita procesos

```bash
# Guardar estado actual
pm2 save

# Configurar auto-inicio
pm2 startup

# Verificar .bashrc
grep "pm2 resurrect" ~/.bashrc
```

---

## 🤖 Casos de Uso con IA

- 📱 **Bots de Telegram/WhatsApp** con respuestas de IA
- 📊 **Automatización de Google Sheets** con análisis inteligente
- 🌐 **Integración con APIs de IA** (OpenAI, Claude, etc.)
- 🔔 **Notificaciones inteligentes** con filtrado por IA
- 📰 **Web scraping y resumen** automático con IA
- 🎨 **Generación de imágenes** con Stable Diffusion/DALL-E
- 💬 **Asistentes virtuales** personalizados
- 📧 **Respuesta automática de emails** con contexto

Todo esto **SIN PAGAR VPS**, directamente desde tu móvil.

---

## 📁 Estructura de Archivos

```
~/.n8n/
├── .env                    # Configuración
├── database.sqlite         # Base de datos
├── logs/                   # Logs de n8n
├── start-n8n.sh           # Script de inicio
├── backup.sh              # Script de backup
├── restore.sh             # Script de restauración
└── update.sh              # Script de actualización

~/backups/                  # Backups con timestamp
└── n8n-backup-*.tar.gz
```

---

## 🔧 Comandos PM2 Útiles

```bash
pm2 list                    # Listar procesos
pm2 show n8n               # Detalles de n8n
pm2 logs n8n               # Ver logs
pm2 logs n8n --lines 100   # Ver últimas 100 líneas
pm2 restart n8n            # Reiniciar
pm2 stop n8n               # Detener
pm2 start n8n              # Iniciar
pm2 delete n8n             # Eliminar del PM2
pm2 save                   # Guardar estado actual
pm2 resurrect              # Restaurar procesos guardados
pm2 monit                  # Monitor en tiempo real
```

---

## 🎨 Características del Instalador v2.0

- ✅ **Detección automática** de npm/pnpm
- ✅ **Instalación inteligente** de dependencias
- ✅ **Spinner animado** durante instalación
- ✅ **Logs centralizados** en `~/n8n-install.log`
- ✅ **Verificación de entorno** Termux
- ✅ **Configuración automática** de SQLite
- ✅ **Alias permanentes** en `.bashrc`
- ✅ **Auto-inicio** con PM2
- ✅ **Scripts de utilidad** incluidos
- ✅ **Información de acceso** al finalizar

---

## 🤝 Contribuir

¿Quieres mejorar el proyecto? ¡Contribuciones bienvenidas!

1. Fork el repositorio
2. Crea una rama: `git checkout -b feature/mejora`
3. Commit: `git commit -am 'Agregar mejora'`
4. Push: `git push origin feature/mejora`
5. Abre un Pull Request

---

## 📄 Licencia

[MIT](LICENSE) - Usa, modifica y distribuye libremente.

---

## 🧾 Créditos

- **Autor**: [@tiendastelegram](https://t.me/tiendastelegram)
- **Inspirado por**: Comunidad n8n, Termux e IvanByCinderella
- **Telegram**: https://t.me/tiendastelegram
- **Repo**: https://github.com/kuromi04/n8n-termux-android-ia

---

## 📞 Soporte

¿Problemas? ¿Preguntas?

- 🐛 [Abrir Issue](https://github.com/kuromi04/n8n-termux-android-ia/issues)
- 💬 [Telegram](https://t.me/tiendastelegram)
- 📧 Contacto en el perfil de GitHub

---

## ⭐ ¿Te gustó?

Si este proyecto te fue útil:
- ⭐ Dale una estrella en GitHub
- 🔄 Compártelo con otros
- 💬 Únete al canal de Telegram

---

## 📊 Estadísticas

![GitHub stars](https://img.shields.io/github/stars/kuromi04/n8n-termux-android-ia?style=social)
![GitHub forks](https://img.shields.io/github/forks/kuromi04/n8n-termux-android-ia?style=social)
![GitHub watchers](https://img.shields.io/github/watchers/kuromi04/n8n-termux-android-ia?style=social)

---

## 🎯 Próximas Mejoras

- [ ] Soporte para múltiples instancias de n8n
- [ ] Integración con Docker (si es posible en Termux)
- [ ] Panel de control web para gestión
- [ ] Monitoreo de recursos (CPU, RAM)
- [ ] Notificaciones push cuando n8n se caiga
- [ ] Auto-actualización programada
- [ ] Integración con servicios de túnel (ngrok, cloudflared)

---

**¡Disfruta automatizando desde tu Android! 🚀📱**
