#!/data/data/com.termux/files/usr/bin/bash

#========================================
# n8n Manager - Script de Gestión
# Herramienta para administrar n8n en Termux
# Autor: @tiendastelegram
#========================================

set -e

# Colores
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m'

# Variables
N8N_DIR="$HOME/.n8n"
BACKUP_DIR="$HOME/backups"

#========================================
# Funciones de UI
#========================================

print_header() {
    clear
    echo -e "${PURPLE}"
    echo "╔═══════════════════════════════════════════════════════════╗"
    echo "║                                                           ║"
    echo "║              🛠️  n8n Manager - Termux 🛠️                 ║"
    echo "║                                                           ║"
    echo "╚═══════════════════════════════════════════════════════════╝"
    echo -e "${NC}\n"
}

print_menu() {
    echo -e "${CYAN}┌─────────────────────────────────────────────┐${NC}"
    echo -e "${CYAN}│${NC}  ${YELLOW}Gestión de n8n${NC}                          ${CYAN}│${NC}"
    echo -e "${CYAN}├─────────────────────────────────────────────┤${NC}"
    echo -e "${CYAN}│${NC}  1) 🚀 Iniciar n8n                         ${CYAN}│${NC}"
    echo -e "${CYAN}│${NC}  2) ⏹️  Detener n8n                        ${CYAN}│${NC}"
    echo -e "${CYAN}│${NC}  3) 🔄 Reiniciar n8n                       ${CYAN}│${NC}"
    echo -e "${CYAN}│${NC}  4) 📊 Estado y estadísticas               ${CYAN}│${NC}"
    echo -e "${CYAN}│${NC}  5) 📋 Ver logs en tiempo real             ${CYAN}│${NC}"
    echo -e "${CYAN}├─────────────────────────────────────────────┤${NC}"
    echo -e "${CYAN}│${NC}  ${YELLOW}Mantenimiento${NC}                           ${CYAN}│${NC}"
    echo -e "${CYAN}├─────────────────────────────────────────────┤${NC}"
    echo -e "${CYAN}│${NC}  6) 📦 Actualizar n8n                      ${CYAN}│${NC}"
    echo -e "${CYAN}│${NC}  7) 💾 Crear backup                        ${CYAN}│${NC}"
    echo -e "${CYAN}│${NC}  8) 📂 Restaurar desde backup              ${CYAN}│${NC}"
    echo -e "${CYAN}│${NC}  9) 🗑️  Limpiar logs antiguos              ${CYAN}│${NC}"
    echo -e "${CYAN}├─────────────────────────────────────────────┤${NC}"
    echo -e "${CYAN}│${NC}  ${YELLOW}Configuración${NC}                           ${CYAN}│${NC}"
    echo -e "${CYAN}├─────────────────────────────────────────────┤${NC}"
    echo -e "${CYAN}│${NC} 10) ⚙️  Editar configuración               ${CYAN}│${NC}"
    echo -e "${CYAN}│${NC} 11) 🔐 Configurar autenticación            ${CYAN}│${NC}"
    echo -e "${CYAN}│${NC} 12) 🌐 Ver URLs de acceso                  ${CYAN}│${NC}"
    echo -e "${CYAN}├─────────────────────────────────────────────┤${NC}"
    echo -e "${CYAN}│${NC}  ${YELLOW}Sistema${NC}                                 ${CYAN}│${NC}"
    echo -e "${CYAN}├─────────────────────────────────────────────┤${NC}"
    echo -e "${CYAN}│${NC} 13) 🔍 Diagnóstico del sistema             ${CYAN}│${NC}"
    echo -e "${CYAN}│${NC} 14) 📚 Ver comandos disponibles            ${CYAN}│${NC}"
    echo -e "${CYAN}│${NC} 15) ℹ️  Información del sistema            ${CYAN}│${NC}"
    echo -e "${CYAN}├─────────────────────────────────────────────┤${NC}"
    echo -e "${CYAN}│${NC} 0)  👋 Salir                               ${CYAN}│${NC}"
    echo -e "${CYAN}└─────────────────────────────────────────────┘${NC}\n"
}

#========================================
# Funciones de gestión
#========================================

start_n8n() {
    echo -e "${YELLOW}Iniciando n8n...${NC}"
    
    if pm2 list | grep -q "n8n.*online"; then
        echo -e "${GREEN}✓ n8n ya está corriendo${NC}"
        pm2 show n8n
    else
        # Cargar variables de entorno
        if [ -f "$N8N_DIR/.env" ]; then
            export $(grep -v '^#' "$N8N_DIR/.env" | xargs)
        fi
        
        pm2 start n8n --name n8n -- start
        pm2 save
        
        echo -e "${GREEN}✓ n8n iniciado correctamente${NC}"
        sleep 2
        show_access_info
    fi
    
    read -p "Presiona Enter para continuar..."
}

stop_n8n() {
    echo -e "${YELLOW}Deteniendo n8n...${NC}"
    pm2 stop n8n
    echo -e "${GREEN}✓ n8n detenido${NC}"
    read -p "Presiona Enter para continuar..."
}

restart_n8n() {
    echo -e "${YELLOW}Reiniciando n8n...${NC}"
    pm2 restart n8n
    echo -e "${GREEN}✓ n8n reiniciado${NC}"
    sleep 2
    show_status
    read -p "Presiona Enter para continuar..."
}

show_status() {
    echo -e "${CYAN}═══════════════════════════════════════════${NC}"
    echo -e "${YELLOW}Estado de n8n:${NC}\n"
    pm2 show n8n
    echo -e "\n${CYAN}═══════════════════════════════════════════${NC}"
}

show_logs() {
    echo -e "${YELLOW}Mostrando logs de n8n (Ctrl+C para salir)...${NC}\n"
    sleep 1
    pm2 logs n8n --lines 100
}

update_n8n() {
    echo -e "${YELLOW}Actualizando n8n a la última versión...${NC}\n"
    
    # Detectar package manager
    if command -v pnpm &> /dev/null; then
        PKG_MGR="pnpm"
    else
        PKG_MGR="npm"
    fi
    
    echo -e "${CYAN}Versión actual:${NC}"
    n8n --version 2>/dev/null || echo "No se pudo obtener versión"
    echo ""
    
    read -p "¿Deseas continuar con la actualización? (s/n): " confirm
    if [[ $confirm != [sS] ]]; then
        echo "Actualización cancelada"
        read -p "Presiona Enter para continuar..."
        return
    fi
    
    echo -e "\n${YELLOW}Creando backup antes de actualizar...${NC}"
    create_backup
    
    echo -e "\n${YELLOW}Actualizando con ${PKG_MGR}...${NC}"
    $PKG_MGR install -g n8n@latest
    
    echo -e "\n${YELLOW}Reiniciando n8n...${NC}"
    pm2 restart n8n
    
    echo -e "\n${GREEN}✓ n8n actualizado${NC}"
    echo -e "${CYAN}Nueva versión:${NC}"
    n8n --version
    
    read -p "Presiona Enter para continuar..."
}

create_backup() {
    mkdir -p "$BACKUP_DIR"
    BACKUP_FILE="$BACKUP_DIR/n8n-backup-$(date +%Y%m%d-%H%M%S).tar.gz"
    
    echo -e "${YELLOW}Creando backup...${NC}"
    tar -czf "$BACKUP_FILE" "$N8N_DIR"
    
    echo -e "${GREEN}✓ Backup creado:${NC} $BACKUP_FILE"
    echo -e "${CYAN}Tamaño:${NC} $(du -h "$BACKUP_FILE" | cut -f1)"
    
    # Mostrar lista de backups
    echo -e "\n${CYAN}Backups disponibles:${NC}"
    ls -lh "$BACKUP_DIR" | grep "n8n-backup"
}

restore_backup() {
    echo -e "${CYAN}Backups disponibles:${NC}\n"
    
    # Listar backups con números
    ls -1 "$BACKUP_DIR"/n8n-backup-*.tar.gz 2>/dev/null | nl -w2 -s') '
    
    if [ $? -ne 0 ]; then
        echo -e "${RED}No se encontraron backups${NC}"
        read -p "Presiona Enter para continuar..."
        return
    fi
    
    echo ""
    read -p "Selecciona el número del backup (0 para cancelar): " backup_num
    
    if [ "$backup_num" == "0" ]; then
        echo "Operación cancelada"
        read -p "Presiona Enter para continuar..."
        return
    fi
    
    BACKUP_FILE=$(ls -1 "$BACKUP_DIR"/n8n-backup-*.tar.gz | sed -n "${backup_num}p")
    
    if [ -z "$BACKUP_FILE" ]; then
        echo -e "${RED}Backup no válido${NC}"
        read -p "Presiona Enter para continuar..."
        return
    fi
    
    echo -e "\n${YELLOW}¿Restaurar desde:${NC} $(basename "$BACKUP_FILE")?"
    read -p "Esto sobrescribirá la configuración actual (s/n): " confirm
    
    if [[ $confirm != [sS] ]]; then
        echo "Restauración cancelada"
        read -p "Presiona Enter para continuar..."
        return
    fi
    
    echo -e "\n${YELLOW}Deteniendo n8n...${NC}"
    pm2 stop n8n 2>/dev/null || true
    
    echo -e "${YELLOW}Restaurando backup...${NC}"
    tar -xzf "$BACKUP_FILE" -C "$HOME"
    
    echo -e "${YELLOW}Iniciando n8n...${NC}"
    pm2 start n8n
    
    echo -e "\n${GREEN}✓ Backup restaurado correctamente${NC}"
    read -p "Presiona Enter para continuar..."
}

clean_logs() {
    echo -e "${YELLOW}Limpiando logs antiguos...${NC}\n"
    
    # Mostrar tamaño actual
    if [ -d "$N8N_DIR/logs" ]; then
        CURRENT_SIZE=$(du -sh "$N8N_DIR/logs" | cut -f1)
        echo -e "${CYAN}Tamaño actual de logs:${NC} $CURRENT_SIZE"
    fi
    
    read -p "¿Eliminar logs de más de 7 días? (s/n): " confirm
    
    if [[ $confirm == [sS] ]]; then
        find "$N8N_DIR/logs" -name "*.log" -mtime +7 -delete
        echo -e "${GREEN}✓ Logs antiguos eliminados${NC}"
        
        if [ -d "$N8N_DIR/logs" ]; then
            NEW_SIZE=$(du -sh "$N8N_DIR/logs" | cut -f1)
            echo -e "${CYAN}Nuevo tamaño:${NC} $NEW_SIZE"
        fi
    else
        echo "Operación cancelada"
    fi
    
    read -p "Presiona Enter para continuar..."
}

edit_config() {
    if [ ! -f "$N8N_DIR/.env" ]; then
        echo -e "${RED}Archivo de configuración no encontrado${NC}"
        read -p "Presiona Enter para continuar..."
        return
    fi
    
    echo -e "${CYAN}Editando configuración de n8n...${NC}\n"
    
    # Crear backup de configuración
    cp "$N8N_DIR/.env" "$N8N_DIR/.env.backup-$(date +%Y%m%d-%H%M%S)"
    
    # Detectar editor disponible
    if command -v nano &> /dev/null; then
        nano "$N8N_DIR/.env"
    elif command -v vim &> /dev/null; then
        vim "$N8N_DIR/.env"
    elif command -v vi &> /dev/null; then
        vi "$N8N_DIR/.env"
    else
        echo -e "${RED}No se encontró ningún editor de texto${NC}"
        echo -e "${YELLOW}Instala nano con: pkg install nano${NC}"
        read -p "Presiona Enter para continuar..."
        return
    fi
    
    echo -e "\n${YELLOW}Reiniciar n8n para aplicar cambios? (s/n):${NC} "
    read confirm
    
    if [[ $confirm == [sS] ]]; then
        pm2 restart n8n
        echo -e "${GREEN}✓ n8n reiniciado con nueva configuración${NC}"
    fi
    
    read -p "Presiona Enter para continuar..."
}

configure_auth() {
    echo -e "${CYAN}Configuración de Autenticación${NC}\n"
    
    echo "1) Activar autenticación básica"
    echo "2) Desactivar autenticación"
    echo "3) Cambiar usuario/contraseña"
    echo "0) Volver"
    echo ""
    read -p "Opción: " auth_option
    
    case $auth_option in
        1)
            read -p "Usuario: " username
            read -sp "Contraseña: " password
            echo ""
            
            # Actualizar .env
            sed -i "s/N8N_BASIC_AUTH_ACTIVE=.*/N8N_BASIC_AUTH_ACTIVE=true/" "$N8N_DIR/.env"
            sed -i "s/N8N_BASIC_AUTH_USER=.*/N8N_BASIC_AUTH_USER=$username/" "$N8N_DIR/.env"
            sed -i "s/N8N_BASIC_AUTH_PASSWORD=.*/N8N_BASIC_AUTH_PASSWORD=$password/" "$N8N_DIR/.env"
            
            pm2 restart n8n
            echo -e "\n${GREEN}✓ Autenticación activada${NC}"
            ;;
        2)
            sed -i "s/N8N_BASIC_AUTH_ACTIVE=.*/N8N_BASIC_AUTH_ACTIVE=false/" "$N8N_DIR/.env"
            pm2 restart n8n
            echo -e "${GREEN}✓ Autenticación desactivada${NC}"
            ;;
        3)
            read -p "Nuevo usuario: " username
            read -sp "Nueva contraseña: " password
            echo ""
            
            sed -i "s/N8N_BASIC_AUTH_USER=.*/N8N_BASIC_AUTH_USER=$username/" "$N8N_DIR/.env"
            sed -i "s/N8N_BASIC_AUTH_PASSWORD=.*/N8N_BASIC_AUTH_PASSWORD=$password/" "$N8N_DIR/.env"
            
            pm2 restart n8n
            echo -e "\n${GREEN}✓ Credenciales actualizadas${NC}"
            ;;
        0)
            return
            ;;
    esac
    
    read -p "Presiona Enter para continuar..."
}

show_access_info() {
    echo -e "\n${CYAN}═══════════════════════════════════════════${NC}"
    echo -e "${YELLOW}URLs de acceso a n8n:${NC}\n"
    
    # IP local
    LOCAL_IP=$(ifconfig 2>/dev/null | grep 'inet ' | grep -v '127.0.0.1' | head -n1 | awk '{print $2}')
    
    # Puerto desde .env
    PORT=$(grep N8N_PORT "$N8N_DIR/.env" | cut -d'=' -f2)
    PORT=${PORT:-5678}
    
    echo -e "${GREEN}Local:${NC}"
    echo -e "  http://localhost:$PORT"
    echo ""
    
    if [ ! -z "$LOCAL_IP" ]; then
        echo -e "${GREEN}Red local:${NC}"
        echo -e "  http://$LOCAL_IP:$PORT"
        echo ""
        
        # Generar QR para acceso móvil
        if command -v qrencode &> /dev/null; then
            echo -e "${CYAN}QR Code:${NC}"
            qrencode -t ANSIUTF8 "http://$LOCAL_IP:$PORT"
        fi
    fi
    
    echo -e "${CYAN}═══════════════════════════════════════════${NC}"
}

show_diagnostics() {
    echo -e "${CYAN}═══════════════════════════════════════════${NC}"
    echo -e "${YELLOW}Diagnóstico del Sistema${NC}\n"
    
    # Estado de n8n
    echo -e "${GREEN}Estado de n8n:${NC}"
    if pm2 list | grep -q "n8n.*online"; then
        echo -e "  ✓ n8n está corriendo"
    else
        echo -e "  ✗ n8n está detenido"
    fi
    echo ""
    
    # Versiones
    echo -e "${GREEN}Versiones:${NC}"
    echo -e "  Node.js: $(node --version 2>/dev/null || echo 'No instalado')"
    echo -e "  npm: $(npm --version 2>/dev/null || echo 'No instalado')"
    if command -v pnpm &> /dev/null; then
        echo -e "  pnpm: $(pnpm --version)"
    fi
    echo -e "  n8n: $(n8n --version 2>/dev/null || echo 'No instalado')"
    echo -e "  PM2: $(pm2 --version 2>/dev/null || echo 'No instalado')"
    echo ""
    
    # Espacio en disco
    echo -e "${GREEN}Espacio en disco:${NC}"
    df -h "$N8N_DIR" | tail -1 | awk '{print "  Usado: "$3" / "$2" ("$5")"}'
    echo ""
    
    # Tamaño de base de datos
    if [ -f "$N8N_DIR/database.sqlite" ]; then
        echo -e "${GREEN}Base de datos:${NC}"
        echo -e "  Tamaño: $(du -h "$N8N_DIR/database.sqlite" | cut -f1)"
        echo ""
    fi
    
    # Red
    echo -e "${GREEN}Red:${NC}"
    LOCAL_IP=$(ifconfig 2>/dev/null | grep 'inet ' | grep -v '127.0.0.1' | head -n1 | awk '{print $2}')
    echo -e "  IP local: ${LOCAL_IP:-'No detectada'}"
    
    echo -e "\n${CYAN}═══════════════════════════════════════════${NC}"
    read -p "Presiona Enter para continuar..."
}

show_commands() {
    echo -e "${CYAN}═══════════════════════════════════════════${NC}"
    echo -e "${YELLOW}Comandos Disponibles:${NC}\n"
    
    echo -e "${GREEN}Gestión:${NC}"
    echo -e "  n8n              - Iniciar n8n"
    echo -e "  n8n-start        - Iniciar n8n"
    echo -e "  n8n-stop         - Detener n8n"
    echo -e "  n8n-restart      - Reiniciar n8n"
    echo -e "  n8n-status       - Ver estado"
    echo -e "  n8n-logs         - Ver logs"
    echo ""
    
    echo -e "${GREEN}Mantenimiento:${NC}"
    echo -e "  n8n-update       - Actualizar n8n"
    echo -e "  n8n-backup       - Crear backup"
    echo ""
    
    echo -e "${GREEN}PM2:${NC}"
    echo -e "  pm2 list         - Listar procesos"
    echo -e "  pm2 monit        - Monitor en tiempo real"
    echo -e "  pm2 save         - Guardar estado"
    echo ""
    
    echo -e "${CYAN}═══════════════════════════════════════════${NC}"
    read -p "Presiona Enter para continuar..."
}

show_system_info() {
    echo -e "${CYAN}═══════════════════════════════════════════${NC}"
    echo -e "${YELLOW}Información del Sistema${NC}\n"
    
    termux-info 2>/dev/null || {
        echo -e "${GREEN}Termux:${NC}"
        echo -e "  Versión: $(pkg list-installed | grep '^termux-' | head -1)"
        echo ""
    }
    
    echo -e "${GREEN}Sistema:${NC}"
    echo -e "  Android: $(getprop ro.build.version.release)"
    echo -e "  CPU: $(getprop ro.product.cpu.abi)"
    echo -e "  RAM: $(free -h | awk '/^Mem:/ {print $2}')"
    echo ""
    
    echo -e "${CYAN}═══════════════════════════════════════════${NC}"
    read -p "Presiona Enter para continuar..."
}

#========================================
# Menú principal
#========================================

main_menu() {
    while true; do
        print_header
        print_menu
        
        read -p "Selecciona una opción: " option
        
        case $option in
            1) start_n8n ;;
            2) stop_n8n ;;
            3) restart_n8n ;;
            4) show_status; read -p "Presiona Enter para continuar..." ;;
            5) show_logs ;;
            6) update_n8n ;;
            7) create_backup; read -p "Presiona Enter para continuar..." ;;
            8) restore_backup ;;
            9) clean_logs ;;
            10) edit_config ;;
            11) configure_auth ;;
            12) show_access_info; read -p "Presiona Enter para continuar..." ;;
            13) show_diagnostics ;;
            14) show_commands ;;
            15) show_system_info ;;
            0) 
                echo -e "\n${GREEN}¡Hasta luego! 👋${NC}\n"
                exit 0
                ;;
            *)
                echo -e "${RED}Opción no válida${NC}"
                sleep 1
                ;;
        esac
    done
}

# Ejecutar menú principal
main_menu
