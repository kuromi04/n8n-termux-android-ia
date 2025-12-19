#!/data/data/com.termux/files/usr/bin/bash

#========================================
# n8n Termux Installer - Versión 2.0
# Instalador unificado y optimizado
# Autor: @tiendastelegram
# Repo: github.com/kuromi04/n8n-termux-android-ia
#========================================

set -e

# Colores para output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m' # Sin color

# Variables globales
N8N_VERSION="latest"
N8N_DIR="$HOME/.n8n"
BACKUP_DIR="$HOME/backups"
LOG_FILE="$HOME/n8n-install.log"
PACKAGE_MANAGER=""

#========================================
# Funciones de utilidad
#========================================

print_banner() {
    clear
    echo -e "${PURPLE}"
    echo "╔═══════════════════════════════════════════════════════════╗"
    echo "║                                                           ║"
    echo "║          🚀 n8n Termux Installer v2.0 🚀                 ║"
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

spinner() {
    local pid=$1
    local delay=0.1
    local spinstr='|/-\'
    while [ "$(ps a | awk '{print $1}' | grep $pid)" ]; do
        local temp=${spinstr#?}
        printf " [%c]  " "$spinstr"
        local spinstr=$temp${spinstr%"$temp"}
        sleep $delay
        printf "\b\b\b\b\b\b"
    done
    printf "    \b\b\b\b"
}

check_termux() {
    if [ ! -d "/data/data/com.termux" ]; then
        log_error "Este script debe ejecutarse en Termux"
        exit 1
    fi
    log "✓ Entorno Termux detectado"
}

#========================================
# Actualización del sistema
#========================================

update_system() {
    log_info "Actualizando sistema Termux..."
    
    pkg update -y >> "$LOG_FILE" 2>&1 &
    spinner $!
    
    pkg upgrade -y >> "$LOG_FILE" 2>&1 &
    spinner $!
    
    log "✓ Sistema actualizado correctamente"
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
    )
    
    for package in "${packages[@]}"; do
        if ! pkg list-installed | grep -q "^$package"; then
            log_info "Instalando $package..."
            pkg install -y "$package" >> "$LOG_FILE" 2>&1 &
            spinner $!
        else
            log "✓ $package ya está instalado"
        fi
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
        log "✓ Detectado: pnpm"
    elif command -v npm &> /dev/null; then
        PACKAGE_MANAGER="npm"
        log "✓ Detectado: npm"
    else
        log_warning "No se detectó ningún gestor de paquetes"
        install_package_manager
    fi
}

install_package_manager() {
    echo ""
    echo -e "${CYAN}Selecciona el gestor de paquetes a instalar:${NC}"
    echo "1) pnpm (Recomendado - Más rápido y eficiente)"
    echo "2) npm (Estándar)"
    echo ""
    read -p "Opción [1-2]: " pm_choice
    
    case $pm_choice in
        1)
            log_info "Instalando pnpm..."
            npm install -g pnpm >> "$LOG_FILE" 2>&1 &
            spinner $!
            PACKAGE_MANAGER="pnpm"
            log "✓ pnpm instalado correctamente"
            ;;
        2)
            PACKAGE_MANAGER="npm"
            log "✓ Usando npm (ya instalado con Node.js)"
            ;;
        *)
            log_warning "Opción inválida, usando npm por defecto"
            PACKAGE_MANAGER="npm"
            ;;
    esac
}

#========================================
# Instalación de PM2
#========================================

install_pm2() {
    log_info "Instalando PM2 (Process Manager)..."
    
    if command -v pm2 &> /dev/null; then
        log "✓ PM2 ya está instalado"
        return
    fi
    
    $PACKAGE_MANAGER install -g pm2 >> "$LOG_FILE" 2>&1 &
    spinner $!
    
    log "✓ PM2 instalado correctamente"
}

#========================================
# Instalación de n8n
#========================================

install_n8n() {
    log_info "Instalando n8n versión ${N8N_VERSION}..."
    
    # Crear directorio de n8n
    mkdir -p "$N8N_DIR"
    
    # Variables de entorno necesarias para compilación
    export CFLAGS="-I${PREFIX}/include"
    export CPPFLAGS="-I${PREFIX}/include"
    export LDFLAGS="-L${PREFIX}/lib"
    
    # Instalar n8n
    if [ "$PACKAGE_MANAGER" = "pnpm" ]; then
        log_info "Instalando con pnpm..."
        pnpm install -g n8n@${N8N_VERSION} --unsafe-perm >> "$LOG_FILE" 2>&1 &
    else
        log_info "Instalando con npm..."
        npm install -g n8n@${N8N_VERSION} --unsafe-perm >> "$LOG_FILE" 2>&1 &
    fi
    
    spinner $!
    
    # Verificar instalación
    if command -v n8n &> /dev/null; then
        local installed_version=$(n8n --version 2>/dev/null || echo "unknown")
        log "✓ n8n instalado correctamente (versión: $installed_version)"
    else
        log_error "Error al instalar n8n"
        exit 1
    fi
}

#========================================
# Configuración de n8n
#========================================

configure_n8n() {
    log_info "Configurando n8n..."
    
    # Crear archivo de configuración
    cat > "$N8N_DIR/.env" << EOF
# n8n Configuration
N8N_PORT=5678
N8N_HOST=0.0.0.0
N8N_PROTOCOL=http
N8N_USER_FOLDER=$N8N_DIR
NODE_ENV=production

# Database (SQLite)
DB_TYPE=sqlite
DB_SQLITE_DATABASE=$N8N_DIR/database.sqlite

# Security
N8N_BASIC_AUTH_ACTIVE=false
N8N_ENCRYPTION_KEY=$(openssl rand -hex 32)

# Paths
N8N_LOG_LOCATION=$N8N_DIR/logs/
N8N_LOG_LEVEL=info

# Performance
N8N_PAYLOAD_SIZE_MAX=16
EXECUTIONS_DATA_PRUNE=true
EXECUTIONS_DATA_MAX_AGE=168
EOF
    
    # Crear directorio de logs
    mkdir -p "$N8N_DIR/logs"
    mkdir -p "$BACKUP_DIR"
    
    log "✓ n8n configurado correctamente"
}

#========================================
# Crear alias y scripts de inicio
#========================================

setup_aliases() {
    log_info "Configurando alias y scripts..."
    
    # Crear script de inicio
    cat > "$HOME/.n8n/start-n8n.sh" << 'EOF'
#!/data/data/com.termux/files/usr/bin/bash

# Cargar variables de entorno
if [ -f "$HOME/.n8n/.env" ]; then
    export $(grep -v '^#' "$HOME/.n8n/.env" | xargs)
fi

# Verificar si n8n ya está corriendo
if pm2 list | grep -q "n8n"; then
    echo "n8n ya está corriendo"
    pm2 show n8n
else
    # Iniciar n8n con PM2
    pm2 start n8n --name n8n -- start
    pm2 save
    
    echo ""
    echo "✓ n8n iniciado correctamente"
    echo ""
    echo "Accede a n8n en: http://$(ifconfig 2>/dev/null | grep 'inet ' | grep -v '127.0.0.1' | head -n1 | awk '{print $2}'):5678"
    echo ""
    echo "Comandos útiles:"
    echo "  n8n-status  - Ver estado de n8n"
    echo "  n8n-logs    - Ver logs de n8n"
    echo "  n8n-stop    - Detener n8n"
    echo "  n8n-restart - Reiniciar n8n"
fi
EOF
    
    chmod +x "$HOME/.n8n/start-n8n.sh"
    
    # Agregar alias a .bashrc
    if ! grep -q "# n8n Aliases" "$HOME/.bashrc"; then
        cat >> "$HOME/.bashrc" << 'EOF'

# n8n Aliases
alias n8n='$HOME/.n8n/start-n8n.sh'
alias n8n-start='$HOME/.n8n/start-n8n.sh'
alias n8n-stop='pm2 stop n8n'
alias n8n-restart='pm2 restart n8n'
alias n8n-status='pm2 show n8n'
alias n8n-logs='pm2 logs n8n --lines 100'
alias n8n-update='npm install -g n8n@latest && pm2 restart n8n'
alias n8n-backup='tar -czf ~/backups/n8n-backup-$(date +%Y%m%d-%H%M%S).tar.gz ~/.n8n'

# Auto-start PM2 processes
pm2 resurrect 2>/dev/null
EOF
        log "✓ Alias configurados en .bashrc"
    else
        log "✓ Alias ya estaban configurados"
    fi
}

#========================================
# Crear scripts de utilidad
#========================================

create_utility_scripts() {
    log_info "Creando scripts de utilidad..."
    
    # Script de backup
    cat > "$HOME/.n8n/backup.sh" << 'EOF'
#!/data/data/com.termux/files/usr/bin/bash
BACKUP_DIR="$HOME/backups"
mkdir -p "$BACKUP_DIR"
BACKUP_FILE="$BACKUP_DIR/n8n-backup-$(date +%Y%m%d-%H%M%S).tar.gz"

echo "Creando backup de n8n..."
tar -czf "$BACKUP_FILE" "$HOME/.n8n"
echo "✓ Backup creado: $BACKUP_FILE"
EOF
    
    # Script de restore
    cat > "$HOME/.n8n/restore.sh" << 'EOF'
#!/data/data/com.termux/files/usr/bin/bash
if [ -z "$1" ]; then
    echo "Uso: ./restore.sh <archivo-backup.tar.gz>"
    exit 1
fi

echo "Deteniendo n8n..."
pm2 stop n8n 2>/dev/null

echo "Restaurando backup..."
tar -xzf "$1" -C "$HOME"
echo "✓ Backup restaurado"

echo "Iniciando n8n..."
pm2 start n8n
EOF
    
    # Script de actualización
    cat > "$HOME/.n8n/update.sh" << 'EOF'
#!/data/data/com.termux/files/usr/bin/bash
echo "Actualizando n8n a la última versión..."
npm install -g n8n@latest
pm2 restart n8n
echo "✓ n8n actualizado correctamente"
EOF
    
    chmod +x "$HOME/.n8n/backup.sh"
    chmod +x "$HOME/.n8n/restore.sh"
    chmod +x "$HOME/.n8n/update.sh"
    
    log "✓ Scripts de utilidad creados"
}

#========================================
# Información final
#========================================

show_final_info() {
    clear
    print_banner
    
    echo -e "${GREEN}╔═══════════════════════════════════════════════════════════╗${NC}"
    echo -e "${GREEN}║                                                           ║${NC}"
    echo -e "${GREEN}║           ✓ Instalación completada con éxito             ║${NC}"
    echo -e "${GREEN}║                                                           ║${NC}"
    echo -e "${GREEN}╚═══════════════════════════════════════════════════════════╝${NC}"
    echo ""
    
    # Obtener IP local
    LOCAL_IP=$(ifconfig 2>/dev/null | grep 'inet ' | grep -v '127.0.0.1' | head -n1 | awk '{print $2}')
    
    echo -e "${CYAN}📋 Información de acceso:${NC}"
    echo -e "   • URL local: ${YELLOW}http://localhost:5678${NC}"
    echo -e "   • URL red local: ${YELLOW}http://${LOCAL_IP}:5678${NC}"
    echo ""
    
    echo -e "${CYAN}🚀 Comandos disponibles:${NC}"
    echo -e "   • ${GREEN}n8n${NC} o ${GREEN}n8n-start${NC}  - Iniciar n8n"
    echo -e "   • ${GREEN}n8n-stop${NC}                - Detener n8n"
    echo -e "   • ${GREEN}n8n-restart${NC}             - Reiniciar n8n"
    echo -e "   • ${GREEN}n8n-status${NC}              - Ver estado"
    echo -e "   • ${GREEN}n8n-logs${NC}                - Ver logs"
    echo -e "   • ${GREEN}n8n-update${NC}              - Actualizar a última versión"
    echo -e "   • ${GREEN}n8n-backup${NC}              - Crear backup"
    echo ""
    
    echo -e "${CYAN}📁 Directorios importantes:${NC}"
    echo -e "   • n8n data: ${YELLOW}~/.n8n${NC}"
    echo -e "   • Backups: ${YELLOW}~/backups${NC}"
    echo -e "   • Logs: ${YELLOW}~/.n8n/logs${NC}"
    echo ""
    
    echo -e "${YELLOW}⚡ Para aplicar los cambios, ejecuta:${NC}"
    echo -e "   ${GREEN}source ~/.bashrc${NC}"
    echo ""
    
    echo -e "${YELLOW}🎯 Para iniciar n8n ahora mismo:${NC}"
    echo -e "   ${GREEN}n8n${NC}"
    echo ""
    
    echo -e "${PURPLE}📚 Más información:${NC}"
    echo -e "   • Repo: ${CYAN}github.com/kuromi04/n8n-termux-android-ia${NC}"
    echo -e "   • Telegram: ${CYAN}t.me/tiendastelegram${NC}"
    echo ""
    
    log_info "Log de instalación guardado en: $LOG_FILE"
}

#========================================
# Función principal
#========================================

main() {
    print_banner
    
    # Verificar entorno
    check_termux
    
    # Iniciar log
    echo "=== Instalación iniciada el $(date) ===" > "$LOG_FILE"
    
    # Ejecutar pasos de instalación
    update_system
    install_dependencies
    detect_package_manager
    install_pm2
    install_n8n
    configure_n8n
    setup_aliases
    create_utility_scripts
    
    # Mostrar información final
    show_final_info
}

# Ejecutar instalador
main
