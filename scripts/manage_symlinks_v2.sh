#!/bin/bash

# Definir variables del proyecto
PROJECT_DIR=$(pwd)
SYMLINK_DIR="$PROJECT_DIR/symlinks"
PROJECTS_DIR="$PROJECT_DIR/project"

# Crear la carpeta de symlinks si no existe
mkdir -p "$SYMLINK_DIR"

# Función para copiar archivos en lugar de crear symlinks
copy_symlinks() {
    echo "Buscando symlinks en $PROJECTS_DIR..."

    # Encuentra los symlinks y los copia en la carpeta de symlinks
    find "$PROJECTS_DIR" -type l | while read -r symlink; do
        target=$(readlink "$symlink")
        dest="$SYMLINK_DIR/$(dirname "$symlink")/$(basename "$symlink")"
        
        # Crear el directorio de destino si no existe
        mkdir -p "$(dirname "$dest")"
        
        # Verificar si el archivo ya existe en el directorio temporal
        if [ ! -e "$dest" ]; then
            echo "Copiando $target a $dest"
            cp -r "$target" "$dest"
        else
            echo "El archivo $dest ya existe, omitiendo..."
        fi
    done
}

# Función para ejecutar el proyecto en cada subcarpeta
run_projects() {
    echo "Ejecutando proyectos en $PROJECTS_DIR..."

    # Recorrer todas las carpetas dentro de project
    for project in "$PROJECTS_DIR"/*; do
        if [ -d "$project" ]; then
            echo "Entrando en el proyecto: $project"
            cd "$project" || continue  # Cambiar al directorio del proyecto
            
            # Aquí puedes ejecutar tu comando de Flutter, como:
            flutter run
            
            # Volver al directorio anterior
            cd - || exit
        fi
    done
}

# Ejecutar las funciones
copy_symlinks
run_projects

echo "Proceso completado."
