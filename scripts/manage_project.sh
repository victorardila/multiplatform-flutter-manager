#!/bin/bash

# Definir colores brillantes y negrita
RED_BOLD='\033[1;91m'      # Rojo brillante y negrita
GREEN_BOLD='\033[1;92m'    # Verde brillante y negrita
YELLOW_BOLD='\033[1;93m'   # Amarillo brillante y negrita
BLUE_BOLD='\033[1;94m'     # Azul brillante y negrita
NC='\033[0m'               # Sin color (reset)

# Definir variables del proyecto
USER_NAME=$(whoami)
PROJECT_DIR=$(pwd)
MOUNT_POINT="/media/$USER_NAME"
PARTITION=$(df "$PROJECT_DIR" | awk 'NR==2 {print $1}')
PARTITION_LABEL=$(lsblk -o LABEL -n "$PARTITION")
PROJECTS_DIR="$(dirname "$PROJECT_DIR")/project"
PARTITIONS=$(lsblk -o MOUNTPOINT | grep "^/")

# Comprobar si alguna partición está en la ruta del proyecto
PARTITION_FOUND=""
for PARTITION in $PARTITIONS; do
    if [[ "$PROJECT_DIR" == "$PARTITION"* ]]; then
        PARTITION_FOUND="$PARTITION"
        break
    fi
done

verificar_ruta_particion(){
    # Comprobar si el directorio de montaje existe, si no, crearlo
    if [ ! -d "$MOUNT_POINT" ]; then
        mkdir -p "$MOUNT_POINT"
    fi
}

# Función para montar las particiones NTFS en Linux
montar_ntfs_linux() {
    # Montar la partición si no está montada
    if ! mount | grep "$MOUNT_POINT/$PARTITION_LABEL" &> /dev/null; then
        # Montar la partición
        sudo mount -o uid=$(id -u),gid=$(id -g),umask=000 "$PARTITION" "$MOUNT_POINT/$PARTITION_LABEL"
        # Verificar si se montó correctamente
        if mount | grep "$MOUNT_POINT/$PARTITION_LABEL" &> /dev/null; then
            echo -e "${GREEN_BOLD}\nLa partición NTFS se montó correctamente en $MOUNT_POINT/$PARTITION_LABEL.${NC}"
        else
            echo -e "${RED_BOLD}\nNo se pudo montar la partición NTFS.${NC}"
            exit 1
        fi
    fi
}


# Función para mostrar puntos de carga con el mismo color que el texto
mostrar_puntos() {
    local color="$1"
    for i in {1..3}; do
        echo -n -e "${color}."  # Evita el salto de línea y usa el color proporcionado
        sleep 0.5  # Pausa de 0.5 segundos entre cada punto
    done
    echo -e "${NC}"  # Salto de línea al final de los puntos y reseteo de color
}

# Función para verificar si un paquete está instalado
check_installation() {
    package=$1
    if ! command -v "$package" &> /dev/null; then
        echo "$package no está instalado."
        return 1
    else
        echo "$package ya está instalado."
        return 0
    fi
}

# Función para instalar NTFS-3G, macFUSE y Mounty en macOS
install_ntfs3g_macfuse_mounty() {
    # URL SERVICE: https://mounty.app/#installation
    if ! command -v brew &> /dev/null; then
        echo -e "${RED_BOLD}Homebrew no está instalado. Instalando Homebrew...${NC}"
        /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    fi

    if ! brew list --cask macfuse &> /dev/null; then
        echo -e "${YELLOW_BOLD}\nInstalando macFUSE...${NC}"
        brew install --cask macfuse
        echo "Sigue las instrucciones de instalación de macFUSE."
    else
        echo "macFUSE ya está instalado."
    fi

    if ! brew list ntfs-3g-mac &> /dev/null; then
        echo -e "${YELLOW_BOLD}\nInstalando NTFS-3G para macOS...${NC}"
        brew install gromgit/fuse/ntfs-3g-mac
    else
        echo "NTFS-3G ya está instalado."
    fi

    if ! brew list --cask mounty &> /dev/null; then
        echo -e "${YELLOW_BOLD}\nInstalando Mounty...${NC}"
        brew install --cask mounty
    else
        echo "Mounty ya está instalado."
    fi
}

# Función para montar las particiones NTFS con Mounty
montar_con_mounty() {
    echo -e "${GREEN_BOLD}\nEjecutando Mounty para montar particiones NTFS...${NC}"
    open -a "Mounty"
    sleep 5
    MOUNTED=$(mount | grep "$PARTITION_FOUND" | grep "ntfs")
    if [[ -n "$MOUNTED" ]]; then
        echo -e "${GREEN_BOLD}\nLa partición NTFS está montada correctamente.${NC}"
    else
        echo -e "${RED_BOLD}\nNo se pudo montar la partición NTFS con Mounty.${NC}"
        exit 1
    fi
}

# Función para detectar el sistema operativo
detectar_sistema_operativo() {
    if [[ "$OSTYPE" == "linux-gnu"* ]]; then
        echo -n -e "\n${GREEN_BOLD}Running On Linux🐧${NC}"  # Usa -n para no hacer salto de línea
        mostrar_puntos "$GREEN_BOLD"  # Mostrar puntos justo después de la línea con el color verde
        echo -e "${NC}"
        montar_ntfs_linux  # Llama a la función de montaje en Linux
        # Llama al nuevo script para ejecutar los proyectos, pasando el sistema operativo
        bash ./flutter_manager.sh "linux"
    elif [[ "$OSTYPE" == "darwin"* ]]; then
        echo -n -e "\n${BLUE_BOLD}Running On macOS🍏${NC}"  # Usa -n para no hacer salto de línea
        mostrar_puntos "$BLUE_BOLD"  # Mostrar puntos justo después de la línea con el color azul
        echo -e "${NC}"
        montar_con_mounty  # Montar usando Mounty
        bash ./flutter_manager.sh "macos"
    elif [[ "$OSTYPE" == "cygwin" || "$OSTYPE" == "msys" || "$OSTYPE" == "win32" ]]; then
        echo -n -e "\n${YELLOW_BOLD}Running On Windows🪟${NC}"  # Usa -n para no hacer salto de línea
        mostrar_puntos "$YELLOW_BOLD"  # Mostrar puntos justo después de la línea con el color amarillo
        echo -e "${NC}"
        bash ./flutter_manager.sh "windows"
    else
        echo -e "${RED_BOLD}\nSistema operativo no detectado o no compatible.${NC}"
    fi
}

verificar_ruta_particion

# Verificar si se encontró la partición
if [ -n "$PARTITION_FOUND" ]; then
    FILESYSTEM_TYPE=$(lsblk -f | grep "$PARTITION_FOUND" | awk '{print $2}')
    if [[ "$FILESYSTEM_TYPE" == "ntfs" ]]; then
        detectar_sistema_operativo
    else
        echo -e "${RED_BOLD}\nADVERTENCIA: La partición actual no es NTFS.${NC}"
    fi
else
    echo -e "${RED_BOLD}\nNo se encontró ninguna partición que coincida con la ruta del proyecto.${NC}"
fi
