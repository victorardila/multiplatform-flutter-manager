#!/bin/bash
# set -x

# Definir colores brillantes y negrita
RED_BOLD='\033[1;91m'      # Rojo brillante y negrita
GREEN_BOLD='\033[1;92m'    # Verde brillante y negrita
YELLOW_BOLD='\033[1;93m'   # Amarillo brillante y negrita
BLUE_BOLD='\033[1;94m'     # Azul brillante y negrita
NC='\033[0m'               # Sin color (reset)

if [ "$EUID" -ne 0 ]; then
    SUPERUSER_PREFIX="sudo"
else
    SUPERUSER_PREFIX=""
fi

# Definir variables del proyecto
COMMAND_ADMIN=$(
    if [[ "$OSTYPE" == "linux-gnu"* ]]; then
        $SUPERUSER_PREFIX chmod +x manage_project.sh
    elif [[ "$OSTYPE" == "darwin"* ]]; then
        $SUPERUSER_PREFIX chmod +x manage_project.sh
    else
        echo "Sistema operativo no compatible para obtener el LABEL."
        exit 1
    fi
)

USER_NAME=$(
    if [[ "$OSTYPE" == "linux-gnu"* ]]; then
        whoami
    elif [[ "$OSTYPE" == "darwin"* ]]; then
        $HOME
    else
        echo "No se puede obtener el Username"
        exit 1
    fi
)
PROJECT_DIR=$(pwd)
MOUNT_POINT="default"
PARTITION=$(df "$PROJECT_DIR" | awk 'NR==2 {print $1}')
PARTITION_LABEL=$(
    if [[ "$OSTYPE" == "linux-gnu"* ]]; then
        lsblk -o LABEL -n "$PARTITION"
    elif [[ "$OSTYPE" == "darwin"* ]]; then
        diskutil info "$PARTITION" | awk -F': ' '/Volume Name/{print $2}'
    else
        echo "Sistema operativo no compatible para obtener el LABEL."
        exit 1
    fi
)
PROJECTS_DIR="$(dirname "$PROJECT_DIR")/project"
PARTITIONS=$(
    if [[ "$OSTYPE" == "linux-gnu"* ]]; then 
        lsblk -o MOUNTPOINT | grep "^/"
    elif [[ "$OSTYPE" == "darwin"* ]]; then
        diskutil info -all | grep "Mount Point:" | awk '{print $3}'
    elif [[ "$OSTYPE" == "msys"* || "$OSTYPE" == "cygwin"* ]]; then
        wmic logicaldisk get name | grep ":"
    else
        echo "No hay particiones en el disco"
        exit
    fi
)

# Comprobar si alguna partición está en la ruta del proyecto
PARTITION_FOUND=""
for PARTITION in $PARTITIONS; do
    if [[ "$PARTITION" != "/" && "$PROJECT_DIR" == "$PARTITION"* ]]; then
        PARTITION_FOUND="$PARTITION"
        break
    fi
done

verificar_ruta_particion(){
    if [[ "$OSTYPE" == "linux-gnu"* ]]; then 
        MOUNT_POINT="/media/$USER_NAME"
        # Comprobar si el directorio de montaje existe, si no, crearlo
        if [ ! -d "$MOUNT_POINT" ]; then
            mkdir -p "$MOUNT_POINT"
        fi
    elif [[ "$OSTYPE" == "darwin"* ]]; then 
        MOUNT_POINT="/Volumes/$USER_NAME"
        # Comprobar si el directorio de montaje existe, si no, crearlo
        if [ ! -d "$MOUNT_POINT" ]; then
            mkdir -p "$MOUNT_POINT"
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

    # Verificar si macFUSE está instalado
    if ! brew list --cask macfuse &> /dev/null; then
        echo -e "${YELLOW_BOLD}\nInstalando macFUSE...${NC}"
        brew install --cask macfuse
        echo "Sigue las instrucciones de instalación de macFUSE."
    else
        echo "macFUSE ya está instalado."
    fi

    # Verificar si NTFS-3G está instalado
    if ! brew list gromgit/fuse/ntfs-3g-mac &> /dev/null; then
        echo -e "${YELLOW_BOLD}\nInstalando NTFS-3G para macOS...${NC}"
        brew install gromgit/fuse/ntfs-3g-mac
    else
        echo "NTFS-3G ya está instalado."
    fi

    # Verificar si Mounty está instalado
    if [ ! -d "/Applications/Mounty.app" ]; then
        echo -e "${YELLOW_BOLD}\nInstalando Mounty...${NC}"
        brew install --cask mounty
    else
        echo "Mounty ya está instalado."
    fi
}

# Función para montar las particiones NTFS con ntfs-3g
montar_con_ntfs_3g() {
    echo -e "${GREEN_BOLD}\nEjecutando ntfs-3g para montar particiones NTFS...${NC}"
    echo $MOUNT_POINT
    # Intenta montar la partición NTFS con ntfs-3g
    sudo ntfs-3g "$PARTITION" "$MOUNT_POINT"
    
    # Verifica si el montaje fue exitoso
    MOUNTED=$(mount | grep "$PARTITION" | grep "ntfs")
    if [[ -n "$MOUNTED" ]]; then
        echo -e "${GREEN_BOLD}\nLa partición NTFS está montada correctamente.${NC}"
    else
        echo -e "${RED_BOLD}\nNo se pudo montar la partición NTFS con ntfs-3g.${NC}"
        exit 1
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

# Pregunta al usuario si quiere generar un archivo de documentación
generar_doc(){
    echo -e "\n¿Quieres generar un archivo de documentación? (Si)[S/s] o (No)[N/n]"
    
    # Lee un solo carácter sin esperar Enter
    read -r -n 1 respuesta
    tput cuu1      # Mueve el cursor una línea hacia arriba
    tput el        # Borra el contenido de la línea
    # Imprime una nueva línea después de capturar el carácter
    echo

    if [[ "$respuesta" == "s" || "$respuesta" == "S" ]]; then
        tput cuu1      # Mueve el cursor una línea hacia arriba
        tput el        # Borra el contenido de la línea
        # Lógica para generar el archivo de documentación
        echo "Generando archivo de documentación..."
        bash ./docs_manager.sh
    else
        echo "No se generará el archivo de documentación."
    fi
}

# Función para detectar el sistema operativo
detectar_sistema_operativo() {
    if [[ "$OSTYPE" == "linux-gnu"* ]]; then
        echo -n -e "\n${GREEN_BOLD}Running On Linux🐧${NC}"  # Usa -n para no hacer salto de línea
        mostrar_puntos "$GREEN_BOLD"  # Mostrar puntos justo después de la línea con el color verde
        echo -e "${NC}"
        generar_doc
        # Llama al nuevo script para ejecutar los proyectos, pasando el sistema operativo
        bash ./flutter_manager.sh "linux"
    elif [[ "$OSTYPE" == "darwin"* ]]; then
        echo -n -e "\n${BLUE_BOLD}Running On macOS🍏${NC}"  # Usa -n para no hacer salto de línea
        mostrar_puntos "$BLUE_BOLD"  # Mostrar puntos justo después de la línea con el color azul
        echo -e "${NC}"
        generar_doc
        install_ntfs3g_macfuse_mounty
        montar_con_ntfs_3g  # Montar usando Mounty
        bash ./flutter_manager.sh "macos"
    elif [[ "$OSTYPE" == "cygwin" || "$OSTYPE" == "msys" || "$OSTYPE" == "win32" ]]; then
        echo -n -e "\n${YELLOW_BOLD}Running On Windows🪟${NC}"  # Usa -n para no hacer salto de línea
        mostrar_puntos "$YELLOW_BOLD"  # Mostrar puntos justo después de la línea con el color amarillo
        echo -e "${NC}"
        generar_doc
        bash ./flutter_manager.sh "windows"
    else
        echo -e "${RED_BOLD}\nSistema operativo no detectado o no compatible.${NC}"
    fi
}

verificar_ruta_particion

# Verificar si se encontró la partición
if [ -n "$PARTITION_FOUND" ]; then
    FILESYSTEM_TYPE=$(
        if [[ "$OSTYPE" == "linux-gnu"* ]]; then
            lsblk -f | grep "$PARTITION_FOUND" | awk '{print $2}'
        elif [[ "$OSTYPE" == "darwin"* ]]; then
            diskutil info "$PARTITION_FOUND" | grep "File System Personality" | awk -F': ' '{print $2}' | xargs 
        elif [[ "$OSTYPE" == "cwinyg"* || "$OSTYPE" == "msys"* || "$OSTYPE" == "win32"* ]]; then
            wmic logicaldisk where "deviceid='$PARTITION_FOUND'" get filesystem | findstr /i /v "Filesystem"
        else
            echo "Sistema operativo no compatible para obtener el LABEL."
            exit 1
        fi
    )

    if [[ "$FILESYSTEM_TYPE" == "ntfs" || "$FILESYSTEM_TYPE" == "NTFS" ]]; then
        detectar_sistema_operativo
    else
        echo -e "${RED_BOLD}\nADVERTENCIA: La partición actual no es NTFS.${NC}"
    fi
else
    echo -e "${RED_BOLD}\nNo se encontró ninguna partición que coincida con la ruta del proyecto.${NC}"
fi