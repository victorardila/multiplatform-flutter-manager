#!/bin/bash

# Definir variables del proyecto
PROJECT_DIR=$(pwd)
SYMLINK_DIR="$PROJECT_DIR/symlinks"

# Crear la carpeta de symlinks si no existe
mkdir -p "$SYMLINK_DIR"

# Función para copiar archivos en lugar de crear symlinks
copy_symlinks() {
    echo "Buscando symlinks en $PROJECT_DIR..."

    # Encuentra los symlinks y los copia en la carpeta temporal
    find "$PROJECT_DIR/project" -type l | while read -r symlink; do
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

# Ejecutar la función para copiar los symlinks
copy_symlinks

echo "Proceso completado. Los symlinks se copiaron a $SYMLINK_DIR."

