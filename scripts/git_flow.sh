#!/bin/bash

# Definir colores brillantes y negrita
RED_BOLD='\033[1;91m'      # Rojo brillante y negrita
GREEN_BOLD='\033[1;92m'    # Verde brillante y negrita
YELLOW_BOLD='\033[1;93m'   # Amarillo brillante y negrita
BLUE_BOLD='\033[1;94m'     # Azul brillante y negrita
NC='\033[0m'               # Sin color (reset)

# Definir variables del proyecto
PROJECT_DIR="$(dirname "$(pwd)")/project"
# Buscar el proyecto en la carpeta de proyectos
PROJECT_NAME=$(ls "$PROJECT_DIR" | head -n 1)  # Solo necesita un proyecto
PROJECT_PATH="$PROJECT_DIR/$PROJECT_NAME"

#!/bin/bash

# Definir colores brillantes y negrita
RED_BOLD='\033[1;91m'      # Rojo brillante y negrita
GREEN_BOLD='\033[1;92m'    # Verde brillante y negrita
YELLOW_BOLD='\033[1;93m'   # Amarillo brillante y negrita
BLUE_BOLD='\033[1;94m'     # Azul brillante y negrita
NC='\033[0m'               # Sin color (reset)

# Definir variables del proyecto
PROJECT_DIR="$(dirname "$(pwd)")/project"
PROJECT_NAME=$(ls "$PROJECT_DIR" | head -n 1)  # Solo necesita un proyecto
PROJECT_PATH="$PROJECT_DIR/$PROJECT_NAME"

# Abre una nueva terminal y cambia al directorio del proyecto
open_new_terminal(){
    # Simular las teclas Ctrl + Shift + P para abrir la paleta de comandos
    xdotool key "ctrl+shift+p"
    sleep 0.5  # Espera un poco para que se abra la paleta

    # Escribir "Terminal: New Terminal" en la paleta
    xdotool type "Terminal: New Terminal"
    sleep 0.5

    # Simular la tecla Enter para ejecutar el comando
    xdotool key "Return"
    sleep 0.5  # Espera a que la terminal se abra

    # Cambiar al directorio del proyecto en la nueva terminal
    xdotool type "cd $PROJECT_PATH"
    sleep 0.5
    xdotool key "Return"

    # Limpiar la terminal para borrar la salida anterior
    xdotool type "clear"
    sleep 0.5
    xdotool key "Return"
}

open_new_terminal
