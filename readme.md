# Vanity macOS Setup

Este proyecto proporciona un instalador automatizado para configurar un entorno de desarrollo moderno en macOS. Incluye instalación de Zsh, Oh My Zsh, plugins de productividad, Oh My Posh con el tema Catppuccin, Python, Node, Docker, yt-dlp y un `.zshrc` preconfigurado.

El script está diseñado para ejecutarse en macOS Apple Silicon o Intel.

---

## Características principales

El instalador incluye:

### Shell & Terminal

* Instalación y activación automática de **Zsh**
* Instalación de **Oh My Zsh**
* Plugins:

  * `zsh-autosuggestions`
  * `zsh-syntax-highlighting`
  * `macos`
* Configuración de historial extendido y opciones mejoradas del shell
* Descarga automática del archivo `.zshrc` personalizado

### Prompt

* Instalación de **Oh My Posh**
* Descarga del tema **Catppuccin**
* Instalación automática de la Nerd Font necesaria

### Paquetes esenciales

* Homebrew
* curl
* wget
* git
* jq
* unzip

### Lenguajes y runtimes

* **Python**
* **Node.js**

### Contenedores

* **Docker CLI**
* **docker-compose**

### Descargas multimedia

* **yt-dlp**
* **ffmpeg**
* Alias incluidos:

  * `ytv <url>` → descarga videos en `~/Downloads/youtube/video`
  * `ytm <url>` → descarga audio MP3 en `~/Downloads/youtube/audio`

---

## Requisitos

* macOS 12 o superior
* Conexión a internet
* Permisos administrativos para ejecutar comandos con `sudo`

---

## Instalación

1. Clona este repositorio o descarga el script:

   ```bash
   git clone https://github.com/vanity/mac-setup.git
   cd mac-setup
   ```

2. Da permisos de ejecución:

   ```bash
   chmod +x vanity_setup.sh
   ```

3. Ejecuta el instalador:

   ```bash
   ./vanity_setup.sh
   ```

4. Cuando finalice, reinicia la terminal.

---

## ¿Qué hace el script?

El script:

1. Verifica si **Homebrew** está instalado; si no, lo instala.
2. Verifica si **zsh** está instalado; si no, lo instala y lo configura como shell por defecto.
3. Instala:

   * curl, wget, git, jq, unzip
   * Python
   * Node
   * Docker CLI + Compose
   * yt-dlp + ffmpeg
4. Instala **Oh My Zsh** sin modificar archivos existentes.
5. Instala **Oh My Posh** y su fuente recomendada.
6. Descarga el tema **Catppuccin**.
7. Descarga el archivo `.zshrc` desde el repositorio.
8. Configura:

   * autosuggestions
   * syntax highlighting
   * historial extendido
   * alias para yt-dlp
9. Crea las carpetas necesarias para descargas multimedia.

---

## Estructura de archivos

```
.
├── vanity_setup.sh        # Instalador principal
├── zshrc                  # Archivo .zshrc personalizado
├── README.md              # Este archivo
```

---

## Alias disponibles

Después de instalar:

```
ytv <URL>   # descarga video
ytm <URL>   # descarga audio mp3
ll          # ls -lah
cls         # clear
brewfix     # mantenimiento de Homebrew
```

---

## Soporte

Si deseas extender el script, agregar plugins extra o integrar herramientas mediante contenedores Docker, puedes modificar el archivo `vanity_setup.sh` según lo requieras.

---
