#!/bin/bash

BLUE_BOLD='\033[1;94m'     # Azul brillante y negrita
NC='\033[0m'               # Sin color (reset)

# Definición de variables
PROJECT_DIR=$(pwd)
DOCS_DIR="$(dirname "$PROJECT_DIR")/docs"
PROJECTS_DIR="$(dirname "$PROJECT_DIR")/project"

# Verificar si la carpeta docs existe; si no, crearla
if [[ ! -d "$DOCS_DIR" ]]; then
    mkdir -p "$DOCS_DIR"
    echo "Carpeta 'docs' creada en: $DOCS_DIR"
fi

# Función para obtener la fecha y hora en el formato deseado sin dos puntos
obtener_fecha_hora() {
    date +"%d-%B-%Y_%I-%M%p"
}

# Definir el nombre del archivo usando la fecha y hora actual sin dos puntos
NOMBRE_ARCHIVO="$(obtener_fecha_hora).md"

# Obtener versiones de Flutter, Java y Gradle
FLUTTER_VERSION=$(flutter --version | awk '{print $2}')  # Captura la versión de Flutter
JAVA_VERSION=$(java -version 2>&1 | awk -F '"' '/version/ {print $2}')  # Captura la versión de Java

# Función para instalar Gradle
instalar_gradle() {
    if [[ "$OSTYPE" == "linux-gnu"* ]]; then
        sudo apt update && sudo apt install -y gradle
    elif [[ "$OSTYPE" == "darwin"* ]]; then
        brew install gradle
    elif [[ "$OSTYPE" == "cygwin" || "$OSTYPE" == "msys" || "$OSTYPE" == "win32" ]]; then
        echo -e "${RED_BOLD}Por favor, instale Gradle manualmente desde https://gradle.org/install/.${NC}"
    else
        echo -e "${RED_BOLD}Sistema operativo no compatible para la instalación automática de Gradle.${NC}"
    fi
}

# Verificar si Gradle está instalado
if ! command -v gradle &> /dev/null; then
    echo -e "${RED_BOLD}Gradle no está instalado.${NC}"
    echo -e "${BLUE_BOLD}¿Desea instalar Gradle? (s/n)${NC}"
    read -r respuesta_instalar
    if [[ "$respuesta_instalar" == "s" ]]; then
        sistema_operativo=$(detectar_sistema_operativo)
        instalar_gradle "$sistema_operativo"
    else
        echo "Instalación de Gradle cancelada. No se generará la documentación."
        exit 1
    fi
fi

# Obtener la versión de Gradle cambiando al directorio del proyecto de Flutter
cd "$PROJECT_DIR" || exit
GRADLE_VERSION=$(gradle --version | awk '/Gradle/ {print $2}')
cd - > /dev/null  # Volver al directorio original

# Contenido del archivo Markdown
CONTENIDO="# Documentación del Proyecto\n\n"
CONTENIDO+="## Fecha de Creación\n\n"
CONTENIDO+="$(obtener_fecha_hora)\n\n"
CONTENIDO+="## Versiones de Dependencias\n"
CONTENIDO+="**Flutter SDK:** $FLUTTER_VERSION\n"
CONTENIDO+="**Java:** $JAVA_VERSION\n"
CONTENIDO+="**Gradle:** $GRADLE_VERSION\n\n"
CONTENIDO+="## Descripción del Proyecto\n\n"
CONTENIDO+="Este proyecto es una aplicación de Flutter que permite gestionar diversas funcionalidades.\n\n"
CONTENIDO+="## Características\n\n"
CONTENIDO+="- Característica 1\n"
CONTENIDO+="- Característica 2\n"
CONTENIDO+="- Característica 3\n\n"
CONTENIDO+="## Instalación\n\n"
CONTENIDO+="Para instalar este proyecto, sigue estos pasos:\n\n"
CONTENIDO+="1. Clona el repositorio\n"
CONTENIDO+="2. Navega a la carpeta del proyecto\n"
CONTENIDO+="3. Ejecuta \flutter pub get\\n\n"
CONTENIDO+="## Uso\n\n"
CONTENIDO+="Para ejecutar la aplicación, utiliza el siguiente comando:\n\n"
CONTENIDO+="\`\`\`bash\n"
CONTENIDO+="flutter run\n"
CONTENIDO+="\`\`\`\n\n"

# Crear el archivo en la carpeta de documentación y escribir el contenido en él
echo -e "$CONTENIDO" > "$DOCS_DIR/$NOMBRE_ARCHIVO"

# Verificar si el archivo se creó correctamente
if [[ $? -eq 0 ]]; then
    sleep 1
    tput cuu1      # Mueve el cursor una línea hacia arriba
    tput el        # Borra el contenido de la línea
    echo -e "${BLUE_BOLD}\nDocumentación creada exitosamente ${NC}\n"
else
    echo "Error al crear la documentación."
fi
