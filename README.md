# Multiplatform Flutter Manager

Este proyecto está diseñado para manejar la creación de enlaces simbólicos en sistemas de archivos que no soportan symlinks, como exFAT. La estructura permite trabajar con proyectos Flutter en una partición exFAT compartida entre Linux, Windows y macOS sin problemas con los symlinks.

![logo](https://github.com/user-attachments/assets/436dac20-1612-499e-9687-08885052709e)

## Estructura del proyecto

- **project/**: Proyecto principal de Flutter.
- **symlinks/**: Carpeta temporal donde se copiarán los archivos en lugar de crear enlaces simbólicos (symlinks).
- **scripts/**: Scripts que manejan los symlinks.
- **.gitignore**: Archivos o carpetas que no deben ser versionados.
- **README.md**: Documentación general de cómo usar este sistema.

## Requisitos

- Linux, macOS o cualquier sistema que soporte Bash.
- Tener Flutter instalado en el sistema y en el PATH.
- Git para manejar versiones.

## Configuración

- **Clona el repositorio**: Asegúrate de que tu proyecto de Flutter esté versionado en Git.

   ```bash
   git clone https://github.com/usuario/flutter_symlink_manager.git
   ```

## Instrucciones de uso

1. Coloca tu proyecto Flutter dentro de la carpeta `project/`.
2. Ejecuta el script `manage_symlinks.sh` para gestionar los symlinks que tu proyecto necesite en sistemas exFAT.
