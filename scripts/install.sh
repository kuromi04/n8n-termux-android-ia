
#!/data/data/com.termux/files/usr/bin/bash

#========================================
# n8n Termux Installer - Versión 2.1
# Instalador corregido y funcional
# Autor: @maka0024
# Repo: github.com/kuromi04/n8n-termux-android-ia
#========================================

# NO usar set -e global — manejamos errores manualmente para mayor control

# Colores
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m'

# Variables globales
N8N_DIR="$HOME/.n8n"
BACKUP_DIR="$HOME/backups"
LOG_FILE="$HOME/n8n-install.log"
PACKAGE_MANAGER=""
PREFIX="${PREFIX:-/data/data/com.termux/files/usr}"

#========================================
# Funciones de utilidad
#========================================

print_banner() {
    clear
    echo -e "${PURPLE}"
    echo "╔═══════════════════════════════════════════════════════════╗"
    echo "║                                                           ║"
    echo "║          🚀 n8n Termux Installer v2.1 🚀                 ║"
    echo "║                                                           ║"
    echo "║          Instalación optimizada con npm/pnpm             ║"
    echo "║          by @tiendastelegram                             ║"
    echo "║                                                           ║"
    echo "╚═══════════════════════════════════════════════════════════╝"
    echo -e "${NC}"
}

log() {
    echo -e "${GREEN}[$(date +'%H:%M:%S')]${NC} $1" | tee -a "$LOG_FILE"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1" | tee -a "$LOG_FILE"
}

log_warning() {
    echo -e "${YELLOW}[WARN]${NC} $1" | tee -a "$LOG_FILE"
}

log_info() {
    echo -e "${CYAN}[INFO]${NC} $1" | tee -a "$LOG_FILE"
}

# Spinner compatible con Termux (usa pgrep en lugar de "ps a")
spinner() {
    local pid=$1
    local delay=0.15
    local spinstr='|/-\'
    while kill -0 "$pid" 2>/dev/null; do
        local temp=${spinstr#?}
        printf " [%c]  " "$spinstr"
        spinstr=$temp${spinstr%"$temp"}
        sleep $delay
        printf "\b\b\b\b\b\b"
    done
    printf "      \b\b\b\b\b\b"
}

# Obtener IP local de forma compatible con Termux
get_local_ip() {
    ip route get 1.1.1.1 2>/dev/null | awk '{print $7; exit}' \
    || ip addr show 2>/dev/null | grep 'inet ' | grep -v '127.0.0.1' | head -n1 | awk '{print $2}' | cut -d'/' -f1 \
    || echo "desconocida"
}

#========================================
# Verificaciones
#========================================

check_termux() {
    if [ ! -d "/data/data/com.termux" ]; then
        log_error "Este script debe ejecutarse en Termux"
        exit 1
    fi
    log "✓ Entorno Termux detectado"
}

check_storage() {
    # Verificar espacio disponible (mínimo 1GB)
    local available
    available=$(df "$HOME" | awk 'NR==2 {print $4}')
    if [ -n "$available" ] && [ "$available" -lt 1048576 ]; then
        log_warning "Espacio disponible bajo: $(df -h "$HOME" | awk 'NR==2 {print $4}')"
        log_warning "Se recomienda al menos 1 GB libre"
        read -p "¿Continuar de todas formas? (s/n): " confirm
        [[ $confirm != [sS] ]] && exit 1
    fi
}

#========================================
# Actualización del sistema
#========================================

update_system() {
    log_info "Actualizando repositorios Termux..."
    pkg update -y >> "$LOG_FILE" 2>&1
    log "✓ Repositorios actualizados"

    log_info "Actualizando paquetes instalados..."
    pkg upgrade -y >> "$LOG_FILE" 2>&1
    log "✓ Paquetes actualizados"
}

#========================================
# Instalación de dependencias base
#========================================

install_dependencies() {
    log_info "Instalando dependencias base..."

    local packages=(
        "nodejs-lts"
        "python"
        "git"
        "sqlite"
        "ndk-sysroot"
        "clang"
        "make"
        "binutils"
        "pkg-config"
        "libjpeg-turbo"
        "libpng"
        "build-essential"
        "iproute2"
    )

    for package in "${packages[@]}"; do
        log_info "Verificando $package..."
        pkg install -y "$package" >> "$LOG_FILE" 2>&1
    done

    log "✓ Dependencias instaladas"
}

#========================================
# Detección e instalación de package manager
#========================================

detect_package_manager() {
    log_info "Detectando gestor de paquetes..."

    if command -v pnpm &> /dev/null; then
        PACKAGE_MANAGER="pnpm"
        log "✓ Detectado: pnpm ($(pnpm --version))"
        return
    fi

    if command -v npm &> /dev/null; then
        PACKAGE_MANAGER="npm"
        log "✓ Detectado: npm ($(npm --version))"
        # Ofrecer instalar pnpm si se desea
        echo ""
        echo -e "${CYAN}¿Deseas instalar pnpm? (más rápido y eficiente que npm)${NC}"
        read -p "Instalar pnpm [s/N]: " use_pnpm
        if [[ $use_pnpm == [sS] ]]; then
            log_info "Instalando pnpm..."
            npm install -g pnpm >> "$LOG_FILE" 2>&1 && {
                PACKAGE_MANAGER="pnpm"
                log "✓ pnpm instalado"
            } || {
                log_warning "No se pudo instalar pnpm, usando npm"
                PACKAGE_MANAGER="npm"
            }
        fi
        return
    fi

    log_error "npm no encontrado. Verifica la instalación de nodejs-lts"
    exit 1
}

#========================================
# Instalación de PM2
#========================================

install_pm2() {
    log_info "Verificando PM2..."

    if command -v pm2 &> /dev/null; then
        log "✓ PM2 ya instalado ($(pm2 --version))"
        return
    fi

    log_info "Instalando PM2..."
    $PACKAGE_MANAGER install -g pm2 >> "$LOG_FILE" 2>&1
    
    if command -v pm2 &> /dev/null; then
        log "✓ PM2 instalado correctamente"
    else
        log_error "Error al instalar PM2"
        exit 1
    fi
}

#========================================
# Instalación de n8n
#========================================

install_n8n() {
    log_info "Instalando n8n (última versión)..."

    mkdir -p "$N8N_DIR"

    # Variables necesarias para compilación de módulos nativos en Termux
    export CFLAGS="-I${PREFIX}/include"
    export CPPFLAGS="-I${PREFIX}/include"
    export LDFLAGS="-L${PREFIX}/lib"
    export npm_config_build_from_source=true

    log_info "Usando: $PACKAGE_MANAGER"

    if [ "$PACKAGE_MANAGER" = "pnpm" ]; then
        pnpm install -g n8n --unsafe-perm >> "$LOG_FILE" 2>&1
    else
        npm install -g n8n --unsafe-perm >> "$LOG_FILE" 2>&1
    fi

    if command -v n8n &> /dev/null; then
        local ver
        ver=$(n8n --version 2>/dev/null || echo "instalado")
        log "✓ n8n instalado correctamente (versión: $ver)"
    else
        log_error "Error al instalar n8n. Revisa: $LOG_FILE"
        exit 1
    fi
}

#========================================
# Configuración de n8n
#========================================

configure_n8n() {
    log_info "Configurando n8n..."

    mkdir -p "$N8N_DIR/logs"
    mkdir -p "$BACKUP_DIR"

    # Generar clave de encriptación
    local enc_key
    enc_key=$(openssl rand -hex 32 2>/dev/null || head -c 32 /dev/urandom | xxd -p | head -c 64)

    cat > "$N8N_DIR/.env" << EOF
# n8n Configuration - generado automáticamente
N8N_PORT=5678
N8N_HOST=0.0.0.0
N8N_PROTOCOL=http
N8N_USER_FOLDER=${N8N_DIR}
NODE_ENV=production

# Base de datos (SQLite)
DB_TYPE=sqlite
DB_SQLITE_DATABASE=${N8N_DIR}/database.sqlite

# Seguridad
N8N_BASIC_AUTH_ACTIVE=false
N8N_BASIC_AUTH_USER=admin
N8N_BASIC_AUTH_PASSWORD=cambia_esto_ahora
N8N_ENCRYPTION_KEY=${enc_key}

# Logs
N8N_LOG_LEVEL=info
N8N_LOG_OUTPUT=file
N8N_LOG_FILE_LOCATION=${N8N_DIR}/logs/n8n.log

# Rendimiento
N8N_PAYLOAD_SIZE_MAX=16
EXECUTIONS_DATA_PRUNE=true
EXECUTIONS_DATA_MAX_AGE=168
EOF

    log "✓ Configuración creada en $N8N_DIR/.env"
}

#========================================
# Script de inicio
#========================================

create_start_script() {
    cat > "$N8N_DIR/start-n8n.sh" << 'STARTSCRIPT'
#!/data/data/com.termux/files/usr/bin/bash

N8N_DIR="$HOME/.n8n"

# Optimizaciones de memoria para n8n en Android (RAM limitada)
# --max-old-space-size evita que Node.js consuma demasiada RAM y sea matado por Android
export NODE_OPTIONS="--max-old-space-size=512"

# Cargar variables de entorno
if [ -f "$N8N_DIR/.env" ]; then
    while IFS='=' read -r key value; do
        [[ "$key" =~ ^#.*$ ]] && continue
        [[ -z "$key" ]] && continue
        export "$key"="$value"
    done < "$N8N_DIR/.env"
fi

# Optimizar SQLite para rendimiento (WAL Mode)
if [ -f "$N8N_DIR/database.sqlite" ]; then
    sqlite3 "$N8N_DIR/database.sqlite" "PRAGMA journal_mode=WAL;" > /dev/null 2>&1
fi

# Verificar si ya está corriendo
if pm2 list 2>/dev/null | grep -q "n8n.*online"; then
    echo "✓ n8n ya está corriendo"
    pm2 show n8n
    exit 0
fi

# Iniciar n8n con PM2 y límites de memoria
echo "Iniciando n8n con optimizaciones de memoria..."
pm2 start n8n --name n8n --node-args="--max-old-space-size=512" -- start 2>/dev/null \
|| pm2 start "$(command -v n8n)" --name n8n --node-args="--max-old-space-size=512" -- start
pm2 save --force

# Obtener IP
LOCAL_IP=$(ip route get 1.1.1.1 2>/dev/null | awk '{print $7; exit}')
PORT=$(grep '^N8N_PORT=' "$N8N_DIR/.env" 2>/dev/null | cut -d'=' -f2)
PORT=${PORT:-5678}

echo ""
echo "✅ n8n iniciado correctamente"
echo ""
echo "📱 Accede en:"
echo "   Local:      http://localhost:${PORT}"
[ -n "$LOCAL_IP" ] && echo "   Red local:  http://${LOCAL_IP}:${PORT}"
echo ""
echo "Comandos útiles:"
echo "  n8n-stop     → Detener"
echo "  n8n-restart  → Reiniciar"
echo "  n8n-logs     → Ver logs"
echo "  n8n-manager  → Gestor visual"
STARTSCRIPT

    chmod +x "$N8N_DIR/start-n8n.sh"
    log "✓ Script de inicio optimizado creado"
}

#========================================
# Alias en .bashrc
#========================================

setup_aliases() {
    log_info "Configurando alias..."

    # Determinar comando de actualización según package manager
    local update_cmd="npm install -g n8n@latest"
    [ "$PACKAGE_MANAGER" = "pnpm" ] && update_cmd="pnpm install -g n8n@latest"

    # Eliminar bloque anterior si existe para evitar duplicados
    if grep -q "# n8n Aliases" "$HOME/.bashrc"; then
        # Borrar el bloque anterior
        sed -i '/# n8n Aliases/,/# fin n8n Aliases/d' "$HOME/.bashrc"
        log_info "Alias anteriores eliminados para reescribir"
    fi

    cat >> "$HOME/.bashrc" << ALIASES

# n8n Aliases
alias n8n='$HOME/.n8n/start-n8n.sh'
alias n8n-start='$HOME/.n8n/start-n8n.sh'
alias n8n-stop='pm2 stop n8n'
alias n8n-restart='pm2 restart n8n'
alias n8n-status='pm2 show n8n'
alias n8n-logs='pm2 logs n8n --lines 100'
alias n8n-update='${update_cmd} && pm2 restart n8n'
alias n8n-backup='\$HOME/.n8n/backup.sh'
alias n8n-manager='bash \$HOME/.n8n/n8n-manager.sh'

# Restaurar procesos PM2 al abrir terminal
if command -v pm2 &>/dev/null; then
    pm2 resurrect 2>/dev/null
fi
# fin n8n Aliases
ALIASES

    log "✓ Alias configurados en ~/.bashrc"
}

#========================================
# Scripts de utilidad
#========================================

create_utility_scripts() {
    log_info "Creando scripts de utilidad..."

    # backup.sh
    cat > "$N8N_DIR/backup.sh" << 'EOF'
#!/data/data/com.termux/files/usr/bin/bash
BACKUP_DIR="$HOME/backups"
mkdir -p "$BACKUP_DIR"
BACKUP_FILE="$BACKUP_DIR/n8n-backup-$(date +%Y%m%d-%H%M%S).tar.gz"
echo "Creando backup..."
tar -czf "$BACKUP_FILE" -C "$HOME" ".n8n"
echo "✓ Backup guardado en: $BACKUP_FILE"
echo "  Tamaño: $(du -h "$BACKUP_FILE" | cut -f1)"
EOF

    # restore.sh
    cat > "$N8N_DIR/restore.sh" << 'EOF'
#!/data/data/com.termux/files/usr/bin/bash
if [ -z "$1" ]; then
    echo "Uso: ~/.n8n/restore.sh <archivo-backup.tar.gz>"
    exit 1
fi
if [ ! -f "$1" ]; then
    echo "Error: Archivo no encontrado: $1"
    exit 1
fi
echo "Deteniendo n8n..."
pm2 stop n8n 2>/dev/null || true
echo "Restaurando backup..."
tar -xzf "$1" -C "$HOME"
echo "Iniciando n8n..."
pm2 start n8n 2>/dev/null || true
echo "✓ Backup restaurado desde: $1"
EOF

    # update.sh
    cat > "$N8N_DIR/update.sh" << 'EOF'
#!/data/data/com.termux/files/usr/bin/bash
PKG_MGR="npm"
command -v pnpm &>/dev/null && PKG_MGR="pnpm"
echo "Versión actual: $(n8n --version 2>/dev/null || echo 'desconocida')"
echo "Actualizando n8n con ${PKG_MGR}..."
$PKG_MGR install -g n8n@latest
pm2 restart n8n
echo "✓ n8n actualizado. Nueva versión: $(n8n --version)"
EOF

    chmod +x "$N8N_DIR/backup.sh" "$N8N_DIR/restore.sh" "$N8N_DIR/update.sh"
    log "✓ Scripts de utilidad creados"
}

#========================================
# Copiar n8n-manager al directorio .n8n
#========================================

install_manager() {
    log_info "Instalando n8n-manager..."

    local manager_url="https://raw.githubusercontent.com/kuromi04/n8n-termux-android-ia/main/scripts/n8n-manager.sh"
    local manager_path="$N8N_DIR/n8n-manager.sh"

    # Si el script está en el mismo directorio, copiarlo
    if [ -f "$(dirname "$0")/n8n-manager.sh" ]; then
        cp "$(dirname "$0")/n8n-manager.sh" "$manager_path"
        chmod +x "$manager_path"
        log "✓ n8n-manager instalado desde archivo local"
    elif curl -fsSL "$manager_url" -o "$manager_path" 2>/dev/null; then
        chmod +x "$manager_path"
        log "✓ n8n-manager descargado correctamente"
    else
        log_warning "No se pudo instalar n8n-manager (continuando sin él)"
    fi
}

#========================================
# Información final
#========================================

show_final_info() {
    local LOCAL_IP
    LOCAL_IP=$(ip route get 1.1.1.1 2>/dev/null | awk '{print $7; exit}' || echo "desconocida")

    clear
    print_banner

    echo -e "${GREEN}╔═══════════════════════════════════════════════════════════╗${NC}"
    echo -e "${GREEN}║          ✅ Instalación completada con éxito              ║${NC}"
    echo -e "${GREEN}╚═══════════════════════════════════════════════════════════╝${NC}"
    echo ""
    echo -e "${CYAN}📋 Acceso a n8n:${NC}"
    echo -e "   Local:      ${YELLOW}http://localhost:5678${NC}"
    echo -e "   Red local:  ${YELLOW}http://${LOCAL_IP}:5678${NC}"
    echo ""
    echo -e "${CYAN}🚀 Comandos disponibles:${NC}"
    echo -e "   ${GREEN}n8n${NC}           → Iniciar n8n"
    echo -e "   ${GREEN}n8n-stop${NC}      → Detener n8n"
    echo -e "   ${GREEN}n8n-restart${NC}   → Reiniciar n8n"
    echo -e "   ${GREEN}n8n-status${NC}    → Ver estado"
    echo -e "   ${GREEN}n8n-logs${NC}      → Ver logs"
    echo -e "   ${GREEN}n8n-update${NC}    → Actualizar"
    echo -e "   ${GREEN}n8n-backup${NC}    → Crear backup"
    echo -e "   ${GREEN}n8n-manager${NC}   → Gestor visual"
    echo ""
    echo -e "${YELLOW}⚡ IMPORTANTE — Aplica los cambios ejecutando:${NC}"
    echo -e "   ${GREEN}source ~/.bashrc${NC}"
    echo ""
    echo -e "${YELLOW}🎯 Luego inicia n8n con:${NC}"
    echo -e "   ${GREEN}n8n${NC}"
    echo ""
    echo -e "${PURPLE}📚 Recursos:${NC}"
    echo -e "   Repo:     ${CYAN}github.com/kuromi04/n8n-termux-android-ia${NC}"
    echo -e "   Telegram: ${CYAN}t.me/tiendastelegram${NC}"
    echo ""
    echo -e "   Log completo: ${YELLOW}$LOG_FILE${NC}"
}

#========================================
# Main
#========================================

main() {
    print_banner

    check_termux
    check_storage

    echo "=== Instalación iniciada: $(date) ===" > "$LOG_FILE"

    update_system
    install_dependencies
    detect_package_manager
    install_pm2
    install_n8n
    configure_n8n
    create_start_script
    setup_aliases
    create_utility_scripts
    install_manager

    show_final_info
}

main
