# VanityOS Shell — macOS Developer Setup 🚀

Automatiza en pocos minutos un entorno de desarrollo moderno para macOS. VanityOS Shell instala Zsh optimizado, Oh My Posh, utilidades CLI esenciales, Docker CLI (sin Desktop) con Colima, Portainer y Lazydocker, dejando tu `.zshrc` listo para trabajar.

---

## ✨ Qué incluye
- Homebrew configurado para Apple Silicon o Intel.
- Zsh + Oh My Zsh con plugins (`zsh-autosuggestions`, `zsh-syntax-highlighting`, `zsh-completions`).
- Oh My Posh (tema Catppuccin) + fuente Meslo Nerd Font.
- Node.js, Python, Git, direnv y herramientas base de terminal.
- yt-dlp + ffmpeg para descargas directas desde YouTube (video y audio).
- Docker CLI, Colima, Lazydocker y despliegue automático de Portainer CE.
- Archivo `.zshrc` documentado para seguir personalizando tu shell.

## ✅ Requisitos previos
- macOS 12+ (Intel o Apple Silicon).
- Conexión estable a internet y espacio libre (~5 GB para Docker).
- Se recomienda instalar las Xcode Command Line Tools antes de iniciar:
  ```bash
  xcode-select --install
  ```

## 🚀 Instalación rápida
Ejecuta el instalador directamente desde la terminal (usa bash, no zsh):
```bash
curl -fsSL https://raw.githubusercontent.com/marcogll/mac_vntySet/main/vanity_setup.sh | bash
```
El script muestra un menú para elegir qué componentes instalar.

## 🧩 Opciones del menú
| Opción | Descripción | Incluye |
|--------|-------------|---------|
| `A`    | Instalación completa (recomendada). | Homebrew + stack Zsh + Docker CLI/Colima/Portainer/Lazydocker. |
| `C`    | Solo configura la terminal. | Homebrew + Zsh, Oh My Zsh, Oh My Posh, utilidades CLI. |
| `D`    | Solo herramientas de contenedores. | Homebrew + Docker CLI, Colima, Portainer, Lazydocker. |
| `Q`    | Salir. | — |

## 🔧 Detalles de la configuración Zsh
- Copia `~/.zshrc` desde `.zshrc.example` (incluye comentarios en español).
- Instala los plugins necesarios y refresca sus repositorios si ya existen.
- Coloca el tema Catppuccin en `~/.poshthemes` y activa Oh My Posh automáticamente.
- Copia `source ~/.zshrc` al portapapeles para que puedas recargar la shell al finalizar.
- Genera los directorios `~/videos/youtube` y `~/musica/youtube` y define alias listos para descargar con `ytv <url>` (video completo) y `ytm <url>` (solo audio MP3).
- Añade un comando `help` dentro de Zsh que describe el uso de estos alias.

## 🐳 Stack Docker + Portainer (sin Desktop)
1. Instala el Docker CLI oficial (`brew install docker docker-buildx docker-compose`).
2. Instala Colima, que levanta el daemon de Docker usando Hypervisor.framework.
3. Intenta iniciar Colima automáticamente con `colima start --cpu 4 --memory 8 --disk 60`.
4. Instala Lazydocker (`brew install lazydocker`).
5. Despliega Portainer CE con los puertos `8000` y `9443`. Acceso: `https://localhost:9443`.

> Si Colima no logra iniciar (por ejemplo, porque falta el permiso de virtualización), el script salta Portainer y te recuerda ejecutar `colima start` manualmente antes de volver a elegir la opción `D`.

## ✅ Verificación rápida
- Recargar Zsh: `source ~/.zshrc`
- Comprobar Oh My Posh: el prompt debe mostrar colores y símbolos; si no, ejecuta `oh-my-posh init zsh --config ~/.poshthemes/catppuccin.omp.json`.
- Verificar Docker: `docker info`
- Confirmar Portainer: abre `https://localhost:9443` en el navegador.
- Lanzar Lazydocker: `lazydocker`
- Descargar un video de prueba: `ytv https://youtu.be/<ID>`
- Descargar solo audio: `ytm https://youtu.be/<ID>`
- Ver ayuda rápida: ejecuta `help`

## 🧰 Personalización
- Edita `~/.zshrc` para añadir alias o funciones propios; el archivo viene por secciones comentadas.
- Cambia el tema de Oh My Posh apuntando a otro `.omp.json` (guárdalo en `~/.poshthemes`).
- Añade paquetes con `brew install <formula>`; el shell ya tiene Homebrew disponible.

## ❗️ Solución de problemas
- **“command not found: brew”**: ejecuta `eval "$(/opt/homebrew/bin/brew shellenv)"` (o `/usr/local/bin/brew`) y vuelve a correr la opción deseada.
- **Docker no arranca**: ejecuta `colima start` (o `colima status` para verificar) y vuelve a lanzar la opción `D` cuando `docker info` funcione.
- **Oh My Posh sin fuente correcta**: instala Meslo manualmente desde `~/Library/Fonts` o selecciona *Meslo LG S DZ Nerd Font* en tu terminal.
- **Conflictos con un `.zshrc` previo**: el instalador hace backup implícito sobrescribiendo `~/.zshrc`. Asegúrate de versionar tu archivo antes si necesitas conservarlo.

## 🧽 Desinstalación rápida
- Elimina Portainer: `docker stop portainer && docker rm portainer && docker volume rm portainer_data`.
- Borra la config Zsh (opcional): `rm -rf ~/.oh-my-zsh ~/.poshthemes ~/.zshrc`.
- Desinstala apps con Homebrew: `brew uninstall docker colima lazydocker oh-my-posh`.

## 📄 Licencia
Distribuido bajo la licencia MIT. Consulta `LICENSE` para más detalles.
