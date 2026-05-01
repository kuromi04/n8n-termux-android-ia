#!/data/data/com.termux/files/usr/bin/bash

#========================================
# n8n Manager - Script de Gestión v2.1
# Corregido para funcionar en Termux
# Autor: @maka0024
#========================================

# Sin set -e — manejamos errores manualmente

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
# Obtener IP compatible con Termux
#========================================
get_local_ip() {
    ip route get 1.1.1.1 2>/dev/null | awk '{print $7; exit}' \
    || ip addr show 2>/dev/null | grep 'inet ' | grep -v '127.0.0.1' | head -n1 | awk '{print $2}' | cut -d'/' -f1 \
    || echo ""
}

#========================================
# UI
#========================================

print_header() {
    clear
    echo -e "${PURPLE}"
    echo "╔═══════════════════════════════════════════════════════════╗"
    echo "║                                                           ║"
    echo "║              🛠️  n8n Manager - Termux v2.1 🛠️            ║"
    echo "║                                                           ║"
    echo "╚═══════════════════════════════════════════════════════════╝"
    echo -e "${NC}"

    # Mostrar estado rápido en el encabezado
    if pm2 list 2>/dev/null | grep -q "n8n.*online"; then
        echo -e "  Estado n8n: ${GREEN}● CORRIENDO${NC}"
    else
        echo -e "  Estado n8n: ${RED}● DETENIDO${NC}"
    fi
    echo ""
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
    echo -e "${CYAN}│${NC} 10) ⚡ Optimizar SQLite (WAL Mode)        ${CYAN}│${NC}"
    echo -e "${CYAN}├─────────────────────────────────────────────┤${NC}"
    echo -e "${CYAN}│${NC}  ${YELLOW}Configuración${NC}                           ${CYAN}│${NC}"
    echo -e "${CYAN}├─────────────────────────────────────────────┤${NC}"
    echo -e "${CYAN}│${NC} 11) ⚙️  Editar configuración               ${CYAN}│${NC}"
    echo -e "${CYAN}│${NC} 12) 🔐 Configurar autenticación            ${CYAN}│${NC}"
    echo -e "${CYAN}│${NC} 13) 🌐 Ver URLs de acceso                  ${CYAN}│${NC}"
    echo -e "${CYAN}├─────────────────────────────────────────────┤${NC}"
    echo -e "${CYAN}│${NC}  ${YELLOW}Sistema${NC}                                 ${CYAN}│${NC}"
    echo -e "${CYAN}├─────────────────────────────────────────────┤${NC}"
    echo -e "${CYAN}│${NC} 14) 🔍 Diagnóstico del sistema             ${CYAN}│${NC}"
    echo -e "${CYAN}│${NC} 15) 📚 Ver comandos disponibles            ${CYAN}│${NC}"
    echo -e "${CYAN}│${NC} 16) ℹ️  Información del sistema            ${CYAN}│${NC}"
    echo -e "${CYAN}├─────────────────────────────────────────────┤${NC}"
    echo -e "${CYAN}│${NC}  0) 👋 Salir                               ${CYAN}│${NC}"
    echo -e "${CYAN}└─────────────────────────────────────────────┘${NC}"
    echo ""
}

#========================================
# Gestión de n8n
#========================================

start_n8n() {
    echo -e "${YELLOW}Iniciando n8n con optimización de memoria...${NC}"

    # Cargar variables de entorno
    if [ -f "$N8N_DIR/.env" ]; then
        while IFS='=' read -r key value; do
            [[ "$key" =~ ^#.*$ ]] && continue
            [[ -z "$key" ]] && continue
            export "$key"="$value"
        done < "$N8N_DIR/.env"
    fi

    # Verificar si el puerto 5678 está ocupado
    local PORT=$(grep '^N8N_PORT=' "$N8N_DIR/.env" 2>/dev/null | cut -d'=' -f2)
    PORT=${PORT:-5678}
    if lsof -Pi :$PORT -sTCP:LISTEN -t >/dev/null ; then
        echo -e "${RED}⚠ El puerto $PORT ya está en uso por otro proceso.${NC}"
        read -p "¿Deseas intentar matar el proceso que ocupa el puerto? (s/n): " kill_port
        if [[ $kill_port == [sS] ]]; then
            fuser -k $PORT/tcp 2>/dev/null || true
            sleep 1
        fi
    fi

    if pm2 list 2>/dev/null | grep -q "n8n.*online"; then
        echo -e "${GREEN}✓ n8n ya está corriendo${NC}"
    else
        # Iniciar con límite de memoria (RAM fija en Android)
        pm2 start n8n --name n8n --node-args="--max-old-space-size=512" -- start 2>/dev/null \
        || pm2 start "$(command -v n8n)" --name n8n --node-args="--max-old-space-size=512" -- start 2>/dev/null \
        || { echo -e "${RED}Error al iniciar n8n. Revisa los logs con: pm2 logs${NC}"; read -p "Enter..."; return; }

        pm2 save --force 2>/dev/null
        echo -e "${GREEN}✓ n8n iniciado con 512MB RAM de límite${NC}"
    fi

    show_access_info
    read -p "Presiona Enter para continuar..."
}

optimize_sqlite() {
    echo -e "${YELLOW}Optimizando base de datos SQLite...${NC}"
    if [ -f "$N8N_DIR/database.sqlite" ]; then
        sqlite3 "$N8N_DIR/database.sqlite" "PRAGMA journal_mode=WAL; PRAGMA synchronous=NORMAL; VACUUM;"
        echo -e "${GREEN}✓ Modo WAL activado y base de datos compactada.${NC}"
    else
        echo -e "${RED}✗ No se encontró la base de datos.${NC}"
    fi
    read -p "Presiona Enter para continuar..."
}

stop_n8n() {
    echo -e "${YELLOW}Deteniendo n8n...${NC}"
    pm2 stop n8n 2>/dev/null && echo -e "${GREEN}✓ n8n detenido${NC}" \
    || echo -e "${RED}n8n no estaba corriendo${NC}"
    read -p "Presiona Enter para continuar..."
}

restart_n8n() {
    echo -e "${YELLOW}Reiniciando n8n...${NC}"
    pm2 restart n8n 2>/dev/null && echo -e "${GREEN}✓ n8n reiniciado${NC}" \
    || echo -e "${RED}Error al reiniciar. ¿Está n8n iniciado?${NC}"
    read -p "Presiona Enter para continuar..."
}

show_status() {
    echo -e "${CYAN}═══════════════════════════════════════════${NC}"
    echo -e "${YELLOW}Estado de n8n:${NC}\n"
    pm2 show n8n 2>/dev/null || echo -e "${RED}n8n no está registrado en PM2${NC}"
    echo -e "${CYAN}═══════════════════════════════════════════${NC}"
    read -p "Presiona Enter para continuar..."
}

show_logs() {
    echo -e "${YELLOW}Logs de n8n — Ctrl+C para salir${NC}\n"
    sleep 1
    pm2 logs n8n --lines 100 2>/dev/null || echo -e "${RED}No se encontraron logs${NC}"
    read -p "Presiona Enter para continuar..."
}

#========================================
# Mantenimiento
#========================================

update_n8n() {
    echo -e "${YELLOW}Actualizar n8n${NC}\n"

    local PKG_MGR="npm"
    command -v pnpm &>/dev/null && PKG_MGR="pnpm"

    echo -e "${CYAN}Package manager:${NC} $PKG_MGR"
    echo -e "${CYAN}Versión actual:${NC}  $(n8n --version 2>/dev/null || echo 'No detectada')"
    echo ""

    read -p "¿Continuar con la actualización? (s/n): " confirm
    [[ $confirm != [sS] ]] && { echo "Cancelado"; read -p "Enter..."; return; }

    echo -e "\n${YELLOW}Creando backup previo...${NC}"
    create_backup_silent

    echo -e "${YELLOW}Actualizando n8n...${NC}"
    $PKG_MGR install -g n8n@latest && {
        pm2 restart n8n 2>/dev/null
        echo -e "${GREEN}✓ Actualizado. Nueva versión: $(n8n --version)${NC}"
    } || echo -e "${RED}Error durante la actualización${NC}"

    read -p "Presiona Enter para continuar..."
}

create_backup_silent() {
    mkdir -p "$BACKUP_DIR"
    local bfile="$BACKUP_DIR/n8n-backup-$(date +%Y%m%d-%H%M%S).tar.gz"
    tar -czf "$bfile" -C "$HOME" ".n8n" 2>/dev/null \
    && echo -e "${GREEN}✓ Backup: $(basename "$bfile")${NC}" \
    || echo -e "${RED}Error al crear backup${NC}"
}

create_backup() {
    echo -e "${YELLOW}Creando backup de n8n...${NC}"
    create_backup_silent

    echo ""
    echo -e "${CYAN}Backups disponibles:${NC}"
    ls -lh "$BACKUP_DIR"/n8n-backup-*.tar.gz 2>/dev/null | awk '{print "  "$9" ("$5")"}' \
    || echo "  (ninguno)"

    read -p "Presiona Enter para continuar..."
}

restore_backup() {
    echo -e "${CYAN}Backups disponibles:${NC}\n"

    local backups
    mapfile -t backups < <(ls -1 "$BACKUP_DIR"/n8n-backup-*.tar.gz 2>/dev/null)

    if [ ${#backups[@]} -eq 0 ]; then
        echo -e "${RED}No se encontraron backups en $BACKUP_DIR${NC}"
        read -p "Presiona Enter para continuar..."
        return
    fi

    local i=1
    for b in "${backups[@]}"; do
        echo "  $i) $(basename "$b") ($(du -h "$b" | cut -f1))"
        ((i++))
    done

    echo ""
    read -p "Selecciona número (0 para cancelar): " num
    [[ "$num" == "0" || -z "$num" ]] && return

    local selected="${backups[$((num-1))]}"
    if [ -z "$selected" ]; then
        echo -e "${RED}Selección inválida${NC}"
        read -p "Enter..."; return
    fi

    echo -e "\n${YELLOW}Restaurar:${NC} $(basename "$selected")"
    read -p "¿Confirmar? Esto sobrescribirá la config actual (s/n): " confirm
    [[ $confirm != [sS] ]] && { echo "Cancelado"; read -p "Enter..."; return; }

    pm2 stop n8n 2>/dev/null || true
    tar -xzf "$selected" -C "$HOME" && {
        pm2 start n8n 2>/dev/null || true
        echo -e "${GREEN}✓ Backup restaurado${NC}"
    } || echo -e "${RED}Error al restaurar${NC}"

    read -p "Presiona Enter para continuar..."
}

clean_logs() {
    echo -e "${YELLOW}Limpieza de logs${NC}\n"

    if [ -d "$N8N_DIR/logs" ]; then
        echo -e "${CYAN}Tamaño actual de logs:${NC} $(du -sh "$N8N_DIR/logs" 2>/dev/null | cut -f1)"
    fi

    read -p "¿Eliminar logs de más de 7 días? (s/n): " confirm
    if [[ $confirm == [sS] ]]; then
        find "$N8N_DIR/logs" -name "*.log" -mtime +7 -delete 2>/dev/null
        # También rotar logs de PM2
        pm2 flush 2>/dev/null
        echo -e "${GREEN}✓ Logs limpiados${NC}"
        [ -d "$N8N_DIR/logs" ] && echo -e "Nuevo tamaño: $(du -sh "$N8N_DIR/logs" 2>/dev/null | cut -f1)"
    else
        echo "Cancelado"
    fi

    read -p "Presiona Enter para continuar..."
}

#========================================
# Configuración
#========================================

edit_config() {
    if [ ! -f "$N8N_DIR/.env" ]; then
        echo -e "${RED}Archivo de configuración no encontrado: $N8N_DIR/.env${NC}"
        read -p "Enter..."; return
    fi

    # Backup de configuración
    cp "$N8N_DIR/.env" "$N8N_DIR/.env.bak-$(date +%Y%m%d-%H%M%S)"

    # Detectar editor
    local editor=""
    for ed in nano vim vi; do
        command -v "$ed" &>/dev/null && { editor="$ed"; break; }
    done

    if [ -z "$editor" ]; then
        echo -e "${RED}No hay editor disponible. Instala nano:${NC}"
        echo "  pkg install nano"
        read -p "Enter..."; return
    fi

    $editor "$N8N_DIR/.env"

    read -p "¿Reiniciar n8n para aplicar cambios? (s/n): " confirm
    [[ $confirm == [sS] ]] && pm2 restart n8n 2>/dev/null && echo -e "${GREEN}✓ Reiniciado${NC}"

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

    # Función auxiliar para establecer/reemplazar clave en .env
    set_env_value() {
        local key="$1"
        local val="$2"
        local envfile="$N8N_DIR/.env"
        if grep -q "^${key}=" "$envfile" 2>/dev/null; then
            # Reemplazar línea existente (compatible con Termux/BSD sed)
            sed -i "s|^${key}=.*|${key}=${val}|" "$envfile"
        else
            # Agregar si no existe
            echo "${key}=${val}" >> "$envfile"
        fi
    }

    case $auth_option in
        1)
            read -p "Usuario: " username
            read -sp "Contraseña: " password
            echo ""
            set_env_value "N8N_BASIC_AUTH_ACTIVE" "true"
            set_env_value "N8N_BASIC_AUTH_USER" "$username"
            set_env_value "N8N_BASIC_AUTH_PASSWORD" "$password"
            pm2 restart n8n 2>/dev/null
            echo -e "${GREEN}✓ Autenticación activada${NC}"
            ;;
        2)
            set_env_value "N8N_BASIC_AUTH_ACTIVE" "false"
            pm2 restart n8n 2>/dev/null
            echo -e "${GREEN}✓ Autenticación desactivada${NC}"
            ;;
        3)
            read -p "Nuevo usuario: " username
            read -sp "Nueva contraseña: " password
            echo ""
            set_env_value "N8N_BASIC_AUTH_USER" "$username"
            set_env_value "N8N_BASIC_AUTH_PASSWORD" "$password"
            pm2 restart n8n 2>/dev/null
            echo -e "${GREEN}✓ Credenciales actualizadas${NC}"
            ;;
        0) return ;;
        *) echo -e "${RED}Opción inválida${NC}" ;;
    esac

    read -p "Presiona Enter para continuar..."
}

show_access_info() {
    local LOCAL_IP
    LOCAL_IP=$(get_local_ip)
    local PORT
    PORT=$(grep '^N8N_PORT=' "$N8N_DIR/.env" 2>/dev/null | cut -d'=' -f2)
    PORT=${PORT:-5678}

    echo ""
    echo -e "${CYAN}═══════════════════════════════════════════${NC}"
    echo -e "${YELLOW}URLs de acceso:${NC}"
    echo -e "  ${GREEN}Local:${NC}     http://localhost:${PORT}"
    [ -n "$LOCAL_IP" ] && echo -e "  ${GREEN}Red local:${NC} http://${LOCAL_IP}:${PORT}"

    # QR si está disponible
    if command -v qrencode &>/dev/null && [ -n "$LOCAL_IP" ]; then
        echo ""
        echo -e "${CYAN}QR para acceso desde otro dispositivo:${NC}"
        qrencode -t ANSIUTF8 "http://${LOCAL_IP}:${PORT}" 2>/dev/null
    fi
    echo -e "${CYAN}═══════════════════════════════════════════${NC}"
}

show_access_info_menu() {
    show_access_info
    read -p "Presiona Enter para continuar..."
}

#========================================
# Sistema
#========================================

show_diagnostics() {
    echo -e "${CYAN}═══════════════════════════════════════════${NC}"
    echo -e "${YELLOW}Diagnóstico del Sistema${NC}\n"

    # Estado n8n
    echo -e "${GREEN}n8n:${NC}"
    if pm2 list 2>/dev/null | grep -q "n8n.*online"; then
        echo -e "  Estado: ${GREEN}● Corriendo${NC}"
    else
        echo -e "  Estado: ${RED}● Detenido${NC}"
    fi
    echo -e "  Versión: $(n8n --version 2>/dev/null || echo 'No detectada')"
    echo ""

    # Versiones
    echo -e "${GREEN}Versiones:${NC}"
    echo -e "  Node.js: $(node --version 2>/dev/null || echo 'No instalado')"
    echo -e "  npm:     $(npm --version 2>/dev/null || echo 'No instalado')"
    command -v pnpm &>/dev/null && echo -e "  pnpm:    $(pnpm --version)"
    echo -e "  PM2:     $(pm2 --version 2>/dev/null || echo 'No instalado')"
    echo ""

    # Espacio en disco
    echo -e "${GREEN}Espacio en disco:${NC}"
    df -h "$HOME" 2>/dev/null | awk 'NR==2 {print "  Usado: "$3" / "$2" ("$5")"}'
    echo ""

    # Base de datos
    if [ -f "$N8N_DIR/database.sqlite" ]; then
        echo -e "${GREEN}Base de datos SQLite:${NC}"
        echo -e "  Tamaño: $(du -h "$N8N_DIR/database.sqlite" | cut -f1)"
        echo ""
    fi

    # Red
    echo -e "${GREEN}Red:${NC}"
    local ip; ip=$(get_local_ip)
    echo -e "  IP local: ${ip:-No detectada}"
    echo ""

    # Uso de memoria del proceso n8n (si está corriendo)
    if pm2 list 2>/dev/null | grep -q "n8n.*online"; then
        echo -e "${GREEN}Proceso n8n (PM2):${NC}"
        pm2 show n8n 2>/dev/null | grep -E "memory usage|cpu usage|restarts|uptime" | sed 's/^/  /'
    fi

    echo -e "\n${CYAN}═══════════════════════════════════════════${NC}"
    read -p "Presiona Enter para continuar..."
}

show_commands() {
    echo -e "${CYAN}═══════════════════════════════════════════${NC}"
    echo -e "${YELLOW}Comandos disponibles${NC}\n"
    echo -e "${GREEN}Gestión:${NC}"
    echo -e "  n8n            → Iniciar n8n"
    echo -e "  n8n-stop       → Detener n8n"
    echo -e "  n8n-restart    → Reiniciar n8n"
    echo -e "  n8n-status     → Ver estado"
    echo -e "  n8n-logs       → Ver logs"
    echo ""
    echo -e "${GREEN}Mantenimiento:${NC}"
    echo -e "  n8n-update     → Actualizar n8n"
    echo -e "  n8n-backup     → Crear backup"
    echo -e "  n8n-manager    → Este gestor visual"
    echo ""
    echo -e "${GREEN}PM2 (directo):${NC}"
    echo -e "  pm2 list       → Listar procesos"
    echo -e "  pm2 monit      → Monitor en tiempo real"
    echo -e "  pm2 save       → Guardar estado"
    echo -e "  pm2 resurrect  → Restaurar procesos guardados"
    echo -e "  pm2 flush      → Limpiar logs de PM2"
    echo -e "${CYAN}═══════════════════════════════════════════${NC}"
    read -p "Presiona Enter para continuar..."
}

show_system_info() {
    echo -e "${CYAN}═══════════════════════════════════════════${NC}"
    echo -e "${YELLOW}Información del Sistema${NC}\n"

    echo -e "${GREEN}Android:${NC}"
    echo -e "  Versión: $(getprop ro.build.version.release 2>/dev/null || echo 'No disponible')"
    echo -e "  CPU ABI: $(getprop ro.product.cpu.abi 2>/dev/null || echo 'No disponible')"
    echo ""

    echo -e "${GREEN}Termux:${NC}"
    echo -e "  Prefijo: ${PREFIX:-/data/data/com.termux/files/usr}"
    echo -e "  Node.js: $(node --version 2>/dev/null || echo 'No instalado')"
    echo ""

    # Memoria — `free` puede no estar disponible, usamos /proc/meminfo
    if [ -f /proc/meminfo ]; then
        local mem_total mem_avail
        mem_total=$(awk '/MemTotal/ {printf "%.0f MB", $2/1024}' /proc/meminfo)
        mem_avail=$(awk '/MemAvailable/ {printf "%.0f MB", $2/1024}' /proc/meminfo)
        echo -e "${GREEN}Memoria:${NC}"
        echo -e "  Total:       $mem_total"
        echo -e "  Disponible:  $mem_avail"
        echo ""
    fi

    echo -e "${GREEN}Almacenamiento (~):${NC}"
    df -h "$HOME" 2>/dev/null | awk 'NR==2 {print "  Total: "$2"  Usado: "$3"  Libre: "$4}'

    echo -e "\n${CYAN}═══════════════════════════════════════════${NC}"
    read -p "Presiona Enter para continuar..."
}

#========================================
# Menú principal
#========================================

main_menu() {
    while true; do
        print_header
        print_menu

        read -p "Selecciona una opción [0-16]: " option

        case $option in
            1)  start_n8n ;;
            2)  stop_n8n ;;
            3)  restart_n8n ;;
            4)  show_status ;;
            5)  show_logs ;;
            6)  update_n8n ;;
            7)  create_backup ;;
            8)  restore_backup ;;
            9)  clean_logs ;;
            10) optimize_sqlite ;;
            11) edit_config ;;
            12) configure_auth ;;
            13) show_access_info_menu ;;
            14) show_diagnostics ;;
            15) show_commands ;;
            16) show_system_info ;;
            0)
                echo -e "\n${GREEN}¡Hasta luego! 👋${NC}\n"
                exit 0
                ;;
            *)
                echo -e "${RED}Opción no válida: $option${NC}"
                sleep 1
                ;;
        esac
    done
}

main_menu
