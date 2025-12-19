# 🚀 Guía de Inicio Rápido - n8n en Termux

## Instalación (3 minutos)

### Paso 1: Instalar en un solo comando

```bash
curl -fsSL https://raw.githubusercontent.com/kuromi04/n8n-termux-android-ia/main/install.sh | bash
```

### Paso 2: Aplicar cambios

```bash
source ~/.bashrc
```

### Paso 3: Iniciar n8n

```bash
n8n
```

**¡Listo!** n8n ya está corriendo en tu dispositivo.

---

## Acceder a n8n

### Desde tu móvil

```
http://localhost:5678
```

### Desde otro dispositivo en la misma red

1. En Termux, ejecuta:
   ```bash
   ifconfig
   ```

2. Busca tu IP (ejemplo: `192.168.1.100`)

3. En el navegador de otro dispositivo:
   ```
   http://192.168.1.100:5678
   ```

---

## Comandos Esenciales

```bash
# Gestión básica
n8n              # Iniciar n8n
n8n-stop         # Detener n8n
n8n-restart      # Reiniciar n8n
n8n-status       # Ver estado
n8n-logs         # Ver logs

# Mantenimiento
n8n-update       # Actualizar a última versión
n8n-backup       # Crear backup

# Gestor visual
n8n-manager      # Abrir menú interactivo
```

---

## Primera Configuración (Opcional)

### Activar autenticación básica

1. Editar configuración:
   ```bash
   nano ~/.n8n/.env
   ```

2. Cambiar estas líneas:
   ```env
   N8N_BASIC_AUTH_ACTIVE=true
   N8N_BASIC_AUTH_USER=tu_usuario
   N8N_BASIC_AUTH_PASSWORD=tu_contraseña
   ```

3. Guardar (Ctrl+O, Enter) y salir (Ctrl+X)

4. Reiniciar n8n:
   ```bash
   n8n-restart
   ```

### Cambiar puerto (si 5678 está ocupado)

1. Editar configuración:
   ```bash
   nano ~/.n8n/.env
   ```

2. Cambiar:
   ```env
   N8N_PORT=8080  # O el puerto que prefieras
   ```

3. Reiniciar n8n:
   ```bash
   n8n-restart
   ```

---

## Primeros Pasos en n8n

### 1. Crear tu primer workflow

1. Abre n8n en el navegador
2. Click en "New workflow" o "Nuevo flujo"
3. Arrastra un nodo "Schedule" (para ejecutar automáticamente)
4. Agrega un nodo "HTTP Request" (para hacer peticiones web)
5. Configura y prueba
6. Activa el workflow

### 2. Ejemplos rápidos

#### Bot de Telegram simple
```
1. Nodo Telegram Trigger (escucha mensajes)
2. Nodo IF (condición)
3. Nodo Telegram (envía respuesta)
```

#### Notificación diaria
```
1. Nodo Schedule (daily at 8:00)
2. Nodo HTTP Request (obtiene datos)
3. Nodo Telegram/Email (envía notificación)
```

#### Guardar en Google Sheets
```
1. Nodo Webhook (recibe datos)
2. Nodo Google Sheets (agrega fila)
```

---

## Integración con IA

### Ejemplo: Bot con ChatGPT

1. **Nodo Telegram Trigger** → Recibe mensaje
2. **Nodo OpenAI** → Procesa con ChatGPT
3. **Nodo Telegram** → Envía respuesta

### Ejemplo: Análisis de imágenes

1. **Nodo Webhook** → Recibe imagen
2. **Nodo OpenAI Vision** → Analiza imagen
3. **Nodo Telegram** → Envía resultado

---

## Troubleshooting Rápido

### n8n no inicia

```bash
# Ver errores
n8n-logs

# Reiniciar PM2
pm2 kill
pm2 resurrect
```

### No puedo acceder desde otro dispositivo

```bash
# Verificar que está en 0.0.0.0
grep N8N_HOST ~/.n8n/.env

# Debe decir: N8N_HOST=0.0.0.0
# Si no, editar:
nano ~/.n8n/.env
# Cambiar y reiniciar:
n8n-restart
```

### Error de compilación

```bash
pkg install -y ndk-sysroot clang make
n8n-update
```

---

## Backups Automáticos

### Crear backup manual

```bash
n8n-backup
```

### Backup automático diario (3 AM)

```bash
# Instalar cronie
pkg install cronie termux-services
sv-enable crond

# Editar crontab
crontab -e

# Agregar línea:
0 3 * * * ~/.n8n/backup.sh
```

---

## Recursos Útiles

- **Documentación oficial n8n**: https://docs.n8n.io/
- **Workflows de ejemplo**: https://n8n.io/workflows/
- **Telegram del proyecto**: https://t.me/tiendastelegram
- **Issues GitHub**: https://github.com/kuromi04/n8n-termux-android-ia/issues

---

## Tips Pro

### 1. Mantén n8n actualizado

```bash
# Revisar versión actual
n8n --version

# Actualizar
n8n-update
```

### 2. Revisa logs regularmente

```bash
n8n-logs
```

### 3. Haz backups antes de cambios importantes

```bash
n8n-backup
```

### 4. Usa el gestor visual para tareas comunes

```bash
n8n-manager
```

### 5. Monitorea recursos con PM2

```bash
pm2 monit
```

---

## Límites y Consideraciones

- ⚠️ **RAM**: n8n puede usar 200-500 MB de RAM
- ⚠️ **CPU**: Workflows complejos pueden ser lentos en móviles antiguos
- ⚠️ **Batería**: Mantener n8n corriendo consume batería
- ⚠️ **Red**: Workflows con muchas peticiones web consumen datos

### Optimizaciones

1. **Limita ejecuciones simultáneas**:
   ```env
   N8N_PAYLOAD_SIZE_MAX=8
   EXECUTIONS_DATA_MAX_AGE=24
   ```

2. **Limpia logs regularmente**:
   ```bash
   # Cada semana
   find ~/.n8n/logs -name "*.log" -mtime +7 -delete
   ```

3. **Desactiva workflows no usados** en la UI de n8n

---

## Preguntas Frecuentes

### ¿n8n funciona sin internet?

Sí, pero solo workflows locales (sin APIs externas).

### ¿Puedo usar múltiples instancias?

Sí, pero necesitas cambiar el puerto para cada una.

### ¿Es seguro exponer n8n a internet?

No sin autenticación y HTTPS. Usa túneles seguros (ngrok, cloudflared).

### ¿Funciona en tablets?

Sí, cualquier dispositivo Android con Termux.

### ¿Consume mucha batería?

Depende de los workflows. Workflows pesados sí, simples no tanto.

---

## Soporte

- 💬 **Telegram**: https://t.me/tiendastelegram
- 🐛 **Issues**: https://github.com/kuromi04/n8n-termux-android-ia/issues
- 📚 **Wiki**: https://github.com/kuromi04/n8n-termux-android-ia/wiki

---

**¡Disfruta automatizando! 🚀**
