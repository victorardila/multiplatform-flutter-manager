# Multiplatform Flutter Manager

Este proyecto está diseñado para manejar la creación de enlaces simbólicos en sistemas de archivos que no soportan symlinks, como exFAT. La estructura permite trabajar con proyectos Flutter en una partición exFAT compartida entre Linux, Windows y macOS sin problemas con los symlinks.

![logo](https://github.com/user-attachments/assets/436dac20-1612-499e-9687-08885052709e)

## Estructura del proyecto

```plaintext
📁 multiplatform-flutter-manager/
│
├── 📁 assets/                       # Recursos del proyecto
│
├── 📁 project/                      # Aquí colocas tu proyecto Flutter
│   └── Tu proyecto Flutter/
│
├── 📁 scripts/                      # Carpeta que contiene el script de gestión
│   └── flutter_manager.sh           # Script que maneja para las tareas de flutter
│   └── manage_project.sh            # Script que maneja la ejecución multiplataforma
│
├── README.md                        # Este archivo que estás leyendo
└── LICENSE                          # Archivo de licencia del proyecto (si aplicable)
```

## `Conveciones`

- **assets/**: Recursos del proyecto
- **project/**: Proyecto principal de Flutter.
- **scripts/**: Scripts que manejan los symlinks.
- **.gitignore**: Archivos o carpetas que no deben ser versionados.
- **README.md**: Documentación general de cómo usar este sistema.

## Requisitos

Asegúrate de tener instalados los siguientes requisitos:

- Linux, macOS o cualquier sistema que soporte Bash.
- Tener Flutter instalado en el sistema y en el PATH. [Flutter SDK](https://flutter.dev/docs/get-started/install)
- Git para manejar versiones.
- Bash (para macOS, Linux, y WSL en Windows)
- Dependencias específicas según el sistema operativo:

### Linux

Instalar dependencias importantes para la ejecucion nativa en linux.

```sh
sudo apt-get install libstdc++-dev
sudo apt-get install libstdc++-12-dev
sudo apt-get install build-essential
```

### macOS

- [Homebrew](https://brew.sh/) para gestionar dependencias adicionales si lo necesitas.

### Windows

- WSL o [Git Bash](https://gitforwindows.org/) recomendado para ejecutar el script.

## Configuración

- **Clona el repositorio**: Asegúrate de que tu proyecto de Flutter esté versionado en Git.

```bash
git clone https://github.com/victorardila/multiplatform-flutter-manager.git
```

## Instrucciones de uso

### 1. Ubicación del Proyecto Flutter

Coloca tu proyecto Flutter en la siguiente carpeta dentro del gestor:

segúrate de que tu proyecto esté ubicado directamente en esa carpeta. El script buscará automáticamente el primer proyecto encontrado.

### 2. Ejecutar el Script

Para ejecutar el script de manejo del proyecto, sigue estos pasos:

### Comando para ejecutar en `bash`

```bash
cd scripts # Ejecuta este comando estando dentro de la raiz del proyecto
./manage_project.sh
```
