#!/bin/bash

# Definir colores brillantes y negrita
RED_BOLD='\033[1;91m'      # Rojo brillante y negrita
GREEN_BOLD='\033[1;92m'    # Verde brillante y negrita
YELLOW_BOLD='\033[1;93m'   # Amarillo brillante y negrita
BLUE_BOLD='\033[1;94m'     # Azul brillante y negrita
NC='\033[0m'               # Sin color (reset)

# Obtener el sistema operativo pasado como argumento
OS_TYPE=$1

# Definir variables del proyecto
PROJECT_DIR="$(dirname "$(pwd)")/project"

# Buscar el proyecto en la carpeta de proyectos
PROJECT_NAME=$(ls "$PROJECT_DIR" | head -n 1)  # Solo necesita un proyecto

# Construir la ruta del directorio de plugins según el sistema operativo
if [[ "$OS_TYPE" == "linux" ]]; then
    FLUTTER_PLUGIN_DIR="$PROJECT_DIR/$PROJECT_NAME/linux/flutter/ephemeral/.plugin_symlinks"
    
    # Verificar e instalar dependencias necesarias
    if ! dpkg -l | grep -q "libstdc++-12-dev"; then
        echo -e "${YELLOW_BOLD}Instalando libstdc++-12-dev...${NC}"
        sudo apt-get install -y libstdc++-12-dev || {
            echo -e "${RED_BOLD}Error al instalar libstdc++-12-dev.${NC}"
            exit 1
        }
    fi

    if ! dpkg -l | grep -q "build-essential"; then
        echo -e "${YELLOW_BOLD}Instalando build-essential...${NC}"
        sudo apt-get install -y build-essential || {
            echo -e "${RED_BOLD}Error al instalar build-essential.${NC}"
            exit 1
        }
    fi
    
elif [[ "$OS_TYPE" == "macos" ]]; then
    FLUTTER_PLUGIN_DIR="$PROJECT_DIR/$PROJECT_NAME/macos/flutter/ephemeral/.plugin_symlinks"
    # Aquí puedes agregar verificaciones específicas para macOS si es necesario

elif [[ "$OS_TYPE" == "windows" ]]; then
    FLUTTER_PLUGIN_DIR="$PROJECT_DIR/$PROJECT_NAME/windows/flutter/ephemeral/.plugin_symlinks"
    # Aquí puedes agregar verificaciones específicas para Windows si es necesario

else
    echo -e "${RED_BOLD}Sistema operativo no reconocido. Saliendo...${NC}"
    exit 1
fi

# Función para eliminar enlaces simbólicos existentes
clean_symlink() {
    local symlink_path="$FLUTTER_PLUGIN_DIR/path_provider_linux"
    if [ -L "$symlink_path" ]; then
        rm "$symlink_path" || {
            echo -e "${RED_BOLD}Error al eliminar el enlace simbólico.${NC}"
            exit 1
        }
    fi
}

run_projects() {
    # Función para ejecutar el proyecto
    cd "$PROJECT_DIR/$PROJECT_NAME" || exit
    clean_symlink

    # Limpiar, obtener dependencias
    flutter clean > /dev/null 2>&1
    flutter pub get > /dev/null 2>&1

    # Ejecutar el proyecto
    flutter run
    # flutter clean > /dev/null 2>&1
    # No es necesario limpiar después, ya que la ejecución debería ser independiente.
}

# Llamar a la función para ejecutar el proyecto
run_projects
