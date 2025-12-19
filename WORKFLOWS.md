# 🤖 Ejemplos de Workflows para n8n en Termux

Esta guía contiene ejemplos prácticos de workflows que puedes implementar en n8n corriendo en tu Android.

---

## 📱 Telegram Bots

### 1. Bot de Respuesta Automática Simple

**Descripción**: Bot que responde automáticamente a mensajes específicos.

**Nodos necesarios**:
1. **Telegram Trigger** (escucha mensajes)
2. **Switch** (evalúa el mensaje)
3. **Telegram** (envía respuesta)

**Configuración**:

```javascript
// En el nodo Switch, agregar casos:
// Caso 1: message.text equals "hola"
// Caso 2: message.text equals "ayuda"
// Caso 3: message.text contains "precio"

// Respuestas correspondientes en nodos Telegram
```

**Uso**: Responde automáticamente a comandos comunes.

---

### 2. Bot con IA (ChatGPT/Claude)

**Descripción**: Bot inteligente que usa IA para responder.

**Nodos necesarios**:
1. **Telegram Trigger**
2. **OpenAI** (o HTTP Request para Claude API)
3. **Telegram**

**Configuración OpenAI**:
```
Resource: Chat
Model: gpt-3.5-turbo
Messages: 
  - Role: system
    Content: "Eres un asistente útil"
  - Role: user
    Content: {{ $json.message.text }}
```

**Variables necesarias**: 
- API Key de OpenAI/Anthropic

---

### 3. Bot de Recordatorios

**Descripción**: Bot que programa recordatorios.

**Nodos necesarios**:
1. **Telegram Trigger** (recibe "/recordar texto")
2. **Code** (parsea comando)
3. **HTTP Request** (guarda en base de datos local)
4. **Telegram** (confirma)

**Workflow separado para enviar**:
1. **Schedule** (cada hora)
2. **HTTP Request** (lee base de datos)
3. **IF** (verifica si hay recordatorios)
4. **Telegram** (envía recordatorio)

---

## 📊 Automatización de Datos

### 4. Guardar datos en Google Sheets

**Descripción**: Recibe datos vía webhook y los guarda en Sheets.

**Nodos necesarios**:
1. **Webhook** (recibe datos)
2. **Google Sheets** (agrega fila)
3. **HTTP Response** (confirma recepción)

**Configuración Webhook**:
```
Method: POST
Path: /save-data
```

**Configuración Google Sheets**:
```
Operation: Append
Sheet: Hoja1
Data to Send: All
```

**Ejemplo de petición**:
```bash
curl -X POST http://tu-ip:5678/webhook/save-data \
  -H "Content-Type: application/json" \
  -d '{"nombre":"Juan","edad":25,"ciudad":"Madrid"}'
```

---

### 5. Sincronización de datos cada hora

**Descripción**: Obtiene datos de una API y los guarda.

**Nodos necesarios**:
1. **Schedule Trigger** (cada hora)
2. **HTTP Request** (obtiene datos)
3. **Google Sheets** (guarda)
4. **Telegram** (notifica si hay errores)

**Configuración Schedule**:
```
Mode: Every Hour
Hour: */1
```

---

## 📰 Web Scraping y Monitoreo

### 6. Monitor de Precios

**Descripción**: Vigila el precio de un producto y notifica cambios.

**Nodos necesarios**:
1. **Schedule Trigger** (cada 30 minutos)
2. **HTTP Request** (obtiene página)
3. **HTML Extract** (extrae precio)
4. **Code** (compara con precio anterior)
5. **IF** (verifica si cambió)
6. **Telegram** (notifica)

**Código de comparación**:
```javascript
// En nodo Code
const precioActual = $input.first().json.precio;
const precioAnterior = $workflow.staticData.precioAnterior || precioActual;

if (precioActual !== precioAnterior) {
  $workflow.staticData.precioAnterior = precioActual;
  return [{
    json: {
      cambio: true,
      precioAnterior,
      precioActual,
      diferencia: precioActual - precioAnterior
    }
  }];
}

return [{ json: { cambio: false } }];
```

---

### 7. RSS Feed a Telegram

**Descripción**: Envía nuevas entradas de RSS a un canal de Telegram.

**Nodos necesarios**:
1. **Schedule Trigger** (cada 15 minutos)
2. **RSS Read** (lee feed)
3. **Code** (filtra nuevas entradas)
4. **Telegram** (envía mensaje)

**Configuración RSS**:
```
URL: https://example.com/feed.xml
```

---

## 🔔 Notificaciones y Alertas

### 8. Alerta de espacio en disco

**Descripción**: Notifica cuando el espacio disponible es bajo.

**Nodos necesarios**:
1. **Schedule Trigger** (diario)
2. **Execute Command** (df -h)
3. **Code** (parsea salida)
4. **IF** (verifica si < 1GB)
5. **Telegram** (envía alerta)

**Comando Execute**:
```bash
df -h /data/data/com.termux | tail -1
```

**Código de parseo**:
```javascript
const output = $input.first().json.stdout;
const usage = parseInt(output.match(/(\d+)%/)[1]);
const available = output.match(/\s+(\S+)\s+\d+%/)[1];

return [{
  json: {
    usage,
    available,
    alert: usage > 90
  }
}];
```

---

### 9. Backup automático diario

**Descripción**: Crea backup de n8n y lo sube a Drive.

**Nodos necesarios**:
1. **Schedule Trigger** (diario a las 3 AM)
2. **Execute Command** (tar backup)
3. **Google Drive** (sube archivo)
4. **Telegram** (confirma éxito)

**Comando de backup**:
```bash
tar -czf /data/data/com.termux/files/home/backups/n8n-$(date +%Y%m%d).tar.gz /data/data/com.termux/files/home/.n8n
```

---

## 🌐 Integraciones API

### 10. Webhook a WhatsApp (vía Twilio/Evolution API)

**Descripción**: Recibe datos y envía mensaje de WhatsApp.

**Nodos necesarios**:
1. **Webhook Trigger**
2. **Code** (formatea mensaje)
3. **HTTP Request** (Twilio/Evolution API)
4. **HTTP Response**

**Configuración HTTP Request (Twilio)**:
```
Method: POST
URL: https://api.twilio.com/2010-04-01/Accounts/YOUR_ACCOUNT_SID/Messages.json
Authentication: Basic Auth
Body:
  From: whatsapp:+14155238886
  To: whatsapp:{{ $json.to }}
  Body: {{ $json.message }}
```

---

### 11. Generación de imágenes con IA

**Descripción**: Genera imágenes con DALL-E/Stable Diffusion.

**Nodos necesarios**:
1. **Telegram Trigger** (recibe prompt)
2. **OpenAI** (genera imagen)
3. **HTTP Request** (descarga imagen)
4. **Telegram** (envía imagen)

**Configuración OpenAI**:
```
Resource: Image
Operation: Generate
Prompt: {{ $json.message.text }}
Size: 512x512
```

---

## 📧 Email Automation

### 12. Auto-responder de emails

**Descripción**: Responde automáticamente a emails específicos.

**Nodos necesarios**:
1. **Email Trigger (IMAP)**
2. **IF** (filtra por subject)
3. **OpenAI** (genera respuesta contextual)
4. **Gmail** (envía respuesta)

**Configuración IMAP**:
```
Host: imap.gmail.com
Port: 993
User: tu-email@gmail.com
Password: [App Password]
```

---

## 🎯 Workflows Avanzados

### 13. Sistema de tickets

**Descripción**: Gestiona tickets de soporte vía Telegram.

**Nodos necesarios**:
1. **Telegram Trigger**
2. **Switch** (comandos: /nuevo, /lista, /cerrar)
3. **Google Sheets** (base de datos de tickets)
4. **Telegram** (respuestas)

**Estructura de Sheet**:
```
ID | Usuario | Fecha | Descripción | Estado | Respuesta
```

---

### 14. Análisis de sentimiento de tweets

**Descripción**: Monitorea hashtags y analiza sentimiento.

**Nodos necesarios**:
1. **Schedule Trigger** (cada hora)
2. **Twitter** (busca tweets)
3. **OpenAI** (análisis de sentimiento)
4. **Google Sheets** (guarda resultados)
5. **IF** (verifica sentimiento negativo)
6. **Telegram** (alerta si negativo)

---

### 15. Pipeline de procesamiento de imágenes

**Descripción**: Recibe imagen, la procesa y extrae texto.

**Nodos necesarios**:
1. **Webhook Trigger**
2. **HTTP Request** (descarga imagen)
3. **Code** (procesa con sharp/jimp)
4. **OpenAI Vision** (extrae texto/describe)
5. **Google Sheets** (guarda resultado)
6. **HTTP Response**

**Código de procesamiento**:
```javascript
// Instalar: npm install sharp
const sharp = require('sharp');
const buffer = Buffer.from($input.first().binary.data, 'base64');

const processed = await sharp(buffer)
  .resize(800)
  .grayscale()
  .toBuffer();

return [{
  json: {},
  binary: {
    data: processed.toString('base64'),
    mimeType: 'image/jpeg'
  }
}];
```

---

## 🛠️ Workflows de Utilidad

### 16. Convertidor de archivos

**Descripción**: Recibe archivo y lo convierte a otro formato.

**Nodos necesarios**:
1. **Webhook Trigger**
2. **Code** (convierte formato)
3. **Telegram** (envía archivo convertido)

**Conversiones soportadas**:
- PDF → Imágenes
- Imágenes → PDF
- Audio → Texto (transcripción)
- Video → Audio

---

### 17. Acortador de URLs personalizado

**Descripción**: Crea URLs cortas personalizadas.

**Nodos necesarios**:
1. **Webhook Trigger** (/shorten)
2. **Code** (genera código único)
3. **Google Sheets** (guarda mapeo)
4. **HTTP Response** (devuelve URL corta)

**Workflow de redirección**:
1. **Webhook Trigger** (/r/:code)
2. **Google Sheets** (busca URL original)
3. **HTTP Response** (redirect 301)

---

### 18. Traductor multilenguaje

**Descripción**: Traduce texto automáticamente.

**Nodos necesarios**:
1. **Telegram Trigger**
2. **Code** (detecta idioma)
3. **OpenAI/DeepL API**
4. **Telegram** (envía traducción)

**Configuración OpenAI**:
```
Model: gpt-3.5-turbo
System: "Traduce el siguiente texto a español"
User: {{ $json.message.text }}
```

---

## 📦 Tips de Implementación

### Variables de entorno

Guarda API keys en `~/.n8n/.env`:
```env
OPENAI_API_KEY=sk-...
TELEGRAM_BOT_TOKEN=123456:ABC...
GOOGLE_SHEETS_CREDENTIALS={"type":"service_account",...}
```

Usa en workflows: `{{ $env.OPENAI_API_KEY }}`

### Manejo de errores

Agrega siempre nodo **Error Trigger** que:
1. Captura errores
2. Registra en log
3. Notifica vía Telegram

### Optimización

- Usa **Function** en vez de **Code** para operaciones simples
- Implementa caché con **Set** y **Code**
- Limita ejecuciones simultáneas en Settings

### Testing

1. Desactiva workflows en producción
2. Duplica y prueba en copia
3. Usa **Manual Trigger** para testing
4. Verifica logs con `n8n-logs`

---

## 🔗 Recursos Adicionales

- **Plantillas oficiales**: https://n8n.io/workflows/
- **Documentación**: https://docs.n8n.io/
- **Community forum**: https://community.n8n.io/
- **YouTube tutorials**: Buscar "n8n workflow examples"

---

## 💡 Ideas para tus propios workflows

1. Monitor de criptomonedas
2. Agregador de noticias personalizado
3. Sistema de reservas automático
4. Bot de moderación de Telegram/Discord
5. Pipeline de contenido para redes sociales
6. Sincronización entre apps (Notion ↔ Todoist)
7. Extractor de datos de PDFs
8. Sistema de encuestas automatizado
9. Monitor de disponibilidad de productos
10. Asistente personal con IA

---

**¡Experimenta y crea tus propios workflows! 🚀**

Para más ayuda: https://t.me/tiendastelegram
