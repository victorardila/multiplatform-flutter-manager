#!/bin/bash

# Definir variables del proyecto
PROJECT_DIR=$(pwd)
# Ajustar PROJECTS_DIR para que esté en el nivel correcto
PROJECTS_DIR="$(dirname "$PROJECT_DIR")/project"

# Obtener las particiones del disco
PARTITIONS=$(lsblk -o MOUNTPOINT | grep "^/")

# Comprobar si alguna partición está en la ruta del proyecto
PARTITION_FOUND=""
for PARTITION in $PARTITIONS; do
    if [[ "$PROJECT_DIR" == "$PARTITION"* ]]; then
        PARTITION_FOUND="$PARTITION"
        break
    fi
done

# Función para ejecutar el proyecto en cada subcarpeta
run_projects() {
    # Recorrer todas las carpetas dentro de project
    for project in "$PROJECTS_DIR"/*; do
        if [ -d "$project" ]; then
            cd "$project" || continue  # Cambiar al directorio del proyecto
            
            # Aquí puedes ejecutar tu comando de Flutter, como:
            flutter run
            
            # Volver al directorio anterior
            cd - || exit
        fi
    done
}

# Función para detectar el sistema operativo
detectar_sistema_operativo() {
    if [[ "$OSTYPE" == "linux-gnu"* ]]; then
        echo "Running Linux🐧..."
        run_projects
    elif [[ "$OSTYPE" == "darwin"* ]]; then
        echo "Running macOS🍏..."
        run_projects
    elif [[ "$OSTYPE" == "cygwin" || "$OSTYPE" == "msys" || "$OSTYPE" == "win32" ]]; then
        echo "Running Windows🪟..."
        run_projects
    else
        echo "Sistema operativo no detectado o no compatible."
    fi
}

# Verificar si se encontró la partición
if [ -n "$PARTITION_FOUND" ]; then
    # Obtener el tipo de sistema de archivos de la partición
    FILESYSTEM_TYPE=$(lsblk -f | grep "$PARTITION_FOUND" | awk '{print $2}')

    # Comprobar si el sistema de archivos es NTFS
    if [[ "$FILESYSTEM_TYPE" == "ntfs" ]]; then
        detectar_sistema_operativo
    else
        echo "ADVERTENCIA: La partición actual no es NTFS."
        echo "Para que el gestor de script funcione correctamente, debe asegurarse de que la partición en la que se ejecuta el script sea NTFS; si no, no va a funcionar."
    fi

else
    echo "No se encontró ninguna partición que coincida con la ruta del proyecto."
fi
