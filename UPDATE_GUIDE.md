# 📝 Guía para Actualizar tu Repositorio en GitHub

Esta guía te ayudará a subir todos los archivos mejorados a tu repositorio GitHub.

---

## 🎯 Archivos Creados

Los siguientes archivos han sido optimizados y están listos para subir:

### Scripts Principales
- ✅ `install.sh` - Instalador unificado con un solo comando
- ✅ `n8n-manager.sh` - Gestor interactivo de n8n

### Documentación
- ✅ `README.md` - Documentación principal actualizada
- ✅ `QUICKSTART.md` - Guía de inicio rápido
- ✅ `WORKFLOWS.md` - Ejemplos de workflows con IA

---

## 📋 Pasos para Actualizar el Repositorio

### Opción 1: Desde tu computadora (Recomendado)

#### 1. Clonar tu repositorio

```bash
git clone https://github.com/kuromi04/n8n-termux-android-ia.git
cd n8n-termux-android-ia
```

#### 2. Descargar los archivos nuevos

Los archivos están disponibles en este chat. Cópialos a tu repositorio local.

#### 3. Organizar archivos

```bash
# Mover scripts a carpeta scripts/
mv install.sh scripts/
mv n8n-manager.sh scripts/

# Documentación en raíz y docs/
# README.md ya está en raíz
mv QUICKSTART.md docs/
mv WORKFLOWS.md docs/
```

#### 4. Eliminar scripts antiguos (opcional)

```bash
# Si quieres reemplazar completamente los antiguos
rm scripts/install_n8n_termux.sh
rm scripts/start_n8n_pm2.sh
rm scripts/backup_n8n.sh
rm scripts/restore_n8n.sh
```

#### 5. Dar permisos de ejecución

```bash
chmod +x scripts/install.sh
chmod +x scripts/n8n-manager.sh
```

#### 6. Agregar cambios a Git

```bash
git add .
git status  # Verifica los cambios
```

#### 7. Hacer commit

```bash
git commit -m "🚀 v2.0: Instalador unificado con npm/pnpm, alias integrados y gestor interactivo

- Nuevo instalador con un solo comando
- Soporte para npm y pnpm
- Sistema de alias (n8n, n8n-start, etc.)
- Gestor interactivo (n8n-manager)
- Instalación automática de última versión
- Documentación completa actualizada
- Guías de workflows con IA
- Scripts de utilidad mejorados"
```

#### 8. Subir a GitHub

```bash
git push origin main
```

---

### Opción 2: Desde la web de GitHub

#### 1. Ir a tu repositorio

```
https://github.com/kuromi04/n8n-termux-android-ia
```

#### 2. Editar/crear archivos

Para cada archivo:

1. Click en el archivo o "Add file" → "Create new file"
2. Pega el contenido del archivo
3. Commit changes

**Archivos a actualizar/crear**:

- `README.md` → Reemplazar con nueva versión
- `scripts/install.sh` → Crear nuevo
- `scripts/n8n-manager.sh` → Crear nuevo
- `docs/QUICKSTART.md` → Crear nuevo
- `docs/WORKFLOWS.md` → Crear nuevo

---

### Opción 3: Desde Termux (Android)

#### 1. Instalar Git en Termux

```bash
pkg install git
```

#### 2. Configurar Git

```bash
git config --global user.name "Tu Nombre"
git config --global user.email "tu@email.com"
```

#### 3. Clonar tu repositorio

```bash
cd ~
git clone https://github.com/kuromi04/n8n-termux-android-ia.git
cd n8n-termux-android-ia
```

#### 4. Crear/editar archivos

```bash
# Crear directorio docs si no existe
mkdir -p docs

# Editar con nano
nano README.md
nano scripts/install.sh
nano scripts/n8n-manager.sh
nano docs/QUICKSTART.md
nano docs/WORKFLOWS.md
```

#### 5. Dar permisos

```bash
chmod +x scripts/install.sh
chmod +x scripts/n8n-manager.sh
```

#### 6. Agregar y commit

```bash
git add .
git commit -m "🚀 v2.0: Major update con instalador unificado"
```

#### 7. Autenticar con GitHub

```bash
# Generar token en GitHub:
# Settings → Developer settings → Personal access tokens → Generate new token
# Permisos: repo (all)

# Pushear con token
git push https://TOKEN@github.com/kuromi04/n8n-termux-android-ia.git main
```

---

## 📁 Estructura Final Recomendada

```
n8n-termux-android-ia/
├── README.md                          # Principal
├── LICENSE
├── .gitignore
│
├── scripts/
│   ├── install.sh                     # ⭐ Nuevo instalador unificado
│   ├── n8n-manager.sh                 # ⭐ Nuevo gestor interactivo
│   └── (opcional: mantener antiguos como legacy/)
│
├── docs/
│   ├── QUICKSTART.md                  # ⭐ Nueva guía rápida
│   ├── WORKFLOWS.md                   # ⭐ Ejemplos de workflows
│   ├── SECURITY.md
│   └── CONTRIBUTING.md
│
├── assets/
│   └── (imágenes, banners, etc.)
│
└── examples/
    └── (archivos de ejemplo de workflows .json)
```

---

## 🎨 Actualizar README con Badge de Versión

Agrega al inicio del README:

```markdown
![Version](https://img.shields.io/badge/version-2.0-blue)
![Last Updated](https://img.shields.io/github/last-commit/kuromi04/n8n-termux-android-ia)
```

---

## 📢 Crear Release en GitHub

### 1. Ir a Releases

```
https://github.com/kuromi04/n8n-termux-android-ia/releases/new
```

### 2. Crear nuevo release

**Tag**: `v2.0`
**Release title**: `🚀 n8n Termux v2.0 - Instalación Unificada`

**Description**:
```markdown
## 🎉 Versión 2.0 - Instalación Revolucionaria

### ✨ Novedades Principales

- 🚀 **Instalación con UN SOLO COMANDO**
- 📦 **Soporte para npm Y pnpm** (tú eliges)
- ⌨️ **Alias integrados** - Escribe `n8n` y listo
- 🔄 **Siempre última versión** de n8n instalada
- 🛠️ **Gestor interactivo** visual (n8n-manager)
- 📚 **Documentación completa** actualizada
- 🤖 **Guías de workflows con IA**

### 📥 Instalación Rápida

```bash
curl -fsSL https://raw.githubusercontent.com/kuromi04/n8n-termux-android-ia/main/scripts/install.sh | bash
```

### 🆕 Comandos Nuevos

- `n8n` - Iniciar n8n
- `n8n-manager` - Gestor interactivo
- `n8n-update` - Actualizar a última versión
- `n8n-backup` - Crear backup

### 📖 Documentación

- [Guía Rápida](docs/QUICKSTART.md)
- [Ejemplos de Workflows](docs/WORKFLOWS.md)
- [README Principal](README.md)

### 🔧 Mejoras Técnicas

- Sistema modular de scripts
- Detección automática de package manager
- Logs centralizados
- Auto-inicio con PM2
- Scripts de utilidad incluidos
- Configuración optimizada de SQLite

### 🐛 Correcciones

- Mejor manejo de errores NDK
- Optimización de compilación
- Configuración de variables de entorno mejorada

### 💬 Soporte

- Telegram: https://t.me/tiendastelegram
- Issues: https://github.com/kuromi04/n8n-termux-android-ia/issues
```

### 3. Adjuntar archivos (opcional)

Puedes agregar los scripts como archivos descargables.

---

## 🔄 Mantener Versiones Antiguas (Opcional)

Si quieres mantener los scripts antiguos:

```bash
# Crear carpeta legacy
mkdir -p scripts/legacy

# Mover scripts antiguos
mv scripts/install_n8n_termux.sh scripts/legacy/
mv scripts/start_n8n_pm2.sh scripts/legacy/
mv scripts/backup_n8n.sh scripts/legacy/
mv scripts/restore_n8n.sh scripts/legacy/

# Crear README en legacy
cat > scripts/legacy/README.md << 'EOF'
# Scripts Legacy (v1.x)

Estos scripts son de la versión anterior (1.x).

**Se recomienda usar la nueva versión 2.0:**
- `scripts/install.sh` - Instalador unificado
- `scripts/n8n-manager.sh` - Gestor interactivo

Los scripts legacy se mantienen solo para compatibilidad.
EOF
```

---

## ✅ Verificación Post-Actualización

### 1. Verificar en GitHub que se subieron todos los archivos

```
https://github.com/kuromi04/n8n-termux-android-ia
```

### 2. Probar la instalación desde cero

```bash
# En Termux limpio
curl -fsSL https://raw.githubusercontent.com/kuromi04/n8n-termux-android-ia/main/scripts/install.sh | bash
```

### 3. Verificar enlaces del README

Asegúrate que todos los enlaces funcionen:
- Badges
- Enlaces a archivos
- Enlaces externos
- Imágenes

---

## 🎯 Checklist Final

- [ ] `README.md` actualizado
- [ ] `install.sh` en `scripts/`
- [ ] `n8n-manager.sh` en `scripts/`
- [ ] `QUICKSTART.md` en `docs/`
- [ ] `WORKFLOWS.md` en `docs/`
- [ ] Permisos de ejecución en scripts
- [ ] Commit con mensaje descriptivo
- [ ] Push a GitHub exitoso
- [ ] Release v2.0 creado
- [ ] Instalación probada desde URL raw
- [ ] README verificado en GitHub

---

## 📧 Anunciar la Actualización

### En Telegram:

```
🚀 ¡NUEVA VERSIÓN 2.0 de n8n para Termux!

✨ Instalación ahora con UN SOLO COMANDO
📦 Soporte para npm y pnpm
⌨️ Alias integrados (solo escribe: n8n)
🛠️ Gestor interactivo incluido

Instalación ultra-rápida:
curl -fsSL https://raw.githubusercontent.com/kuromi04/n8n-termux-android-ia/main/scripts/install.sh | bash

🔗 Repo: github.com/kuromi04/n8n-termux-android-ia
📚 Docs completas y ejemplos de workflows con IA

¡Disfruta automatizando desde tu Android! 🤖📱
```

---

## 🔮 Próximos Pasos (Opcionales)

1. **GitHub Actions** para testing automático
2. **Wiki** con tutoriales paso a paso
3. **Issues templates** para mejor soporte
4. **Discussions** para comunidad
5. **Docker image** (si es viable en Termux)

---

**¡Listo! Tu repositorio está actualizado a la versión 2.0 🎉**

Para más ayuda: https://t.me/tiendastelegram
