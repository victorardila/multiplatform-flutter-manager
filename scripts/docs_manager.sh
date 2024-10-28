#!/bin/bash

# Definicion de variables
PROJECT_DIR=$(pwd)
DOCS_DIR="$(dirname "$PROJECT_DIR")/docs"

# Función para obtener la fecha y hora en el formato deseado
obtener_fecha_hora() {
    date +"%d-%B-%Y_%I:%M%p"
}

# Definir el nombre del archivo usando la fecha y hora actual
NOMBRE_ARCHIVO="$(obtener_fecha_hora).md"

# Contenido del archivo Markdown
CONTENIDO="# Documentación del Proyecto\n\n"
CONTENIDO+="## Fecha de Creación\n"
CONTENIDO+="$(obtener_fecha_hora)\n\n"
CONTENIDO+="## Descripción del Proyecto\n"
CONTENIDO+="Este proyecto es una aplicación de Flutter que permite gestionar diversas funcionalidades.\n\n"
CONTENIDO+="## Características\n"
CONTENIDO+="- Característica 1\n"
CONTENIDO+="- Característica 2\n"
CONTENIDO+="- Característica 3\n\n"
CONTENIDO+="## Instalación\n"
CONTENIDO+="Para instalar este proyecto, sigue estos pasos:\n"
CONTENIDO+="1. Clona el repositorio\n"
CONTENIDO+="2. Navega a la carpeta del proyecto\n"
CONTENIDO+="3. Ejecuta `flutter pub get`\n\n"
CONTENIDO+="## Uso\n"
CONTENIDO+="Para ejecutar la aplicación, utiliza el siguiente comando:\n"
CONTENIDO+="```bash\n"
CONTENIDO+="flutter run\n"
CONTENIDO+="```\n"

# Crear el archivo y escribir el contenido en él
echo -e "$CONTENIDO" > "$DOCS_DIR"

# Verificar si el archivo se creó correctamente
if [[ $? -eq 0 ]]; then
    echo "Documentación creada exitosamente en: $DOCS_DIR"
else
    echo "Error al crear la documentación."
fi
