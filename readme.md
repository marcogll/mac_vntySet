# VanityOS Shell — macOS Developer Setup 🚀

Automatiza en pocos minutos un entorno de desarrollo moderno para macOS. VanityOS Shell instala Zsh optimizado, Oh My Posh, utilidades CLI esenciales, Docker CLI (requiere daemon externo) con Portainer y Lazydocker, dejando tu `.zshrc` listo para trabajar.

---

## ✨ Qué incluye
- Homebrew configurado para Apple Silicon o Intel.
- Zsh + Oh My Zsh con plugins (`zsh-autosuggestions`, `zsh-syntax-highlighting`, `zsh-completions`).
- Oh My Posh (tema Catppuccin) + fuente Meslo Nerd Font.
7- Node.js, Python, Git, direnv y herramientas base de terminal (incluyendo ZeroTier CLI y Speedtest CLI).
- yt-dlp + ffmpeg para descargas directas desde YouTube (video y audio).
- Docker CLI, Lazydocker y despliegue automático de Portainer CE (con Docker Desktop preinstalado y arrancado).
- Ajusta automáticamente la fuente de la app Terminal a Meslo Nerd Font para que Oh My Posh muestre los iconos correctamente.
- Archivo `.zshrc` documentado para seguir personalizando tu shell.

## ✅ Requisitos previos
- macOS 12+ (Intel o Apple Silicon).
- Conexión estable a internet y espacio libre (~5 GB para Docker).
- Las Xcode Command Line Tools se instalan automáticamente si no están presentes; si prefieres hacerlo antes de correr el script, ejecuta:
  ```bash
  xcode-select --install
  ```

## 🚀 Instalación rápida
Ejecuta el instalador directamente desde la terminal (usa bash, no zsh):
```bash
curl -fsSL https://raw.githubusercontent.com/marcogll/mac_vntySet/main/vanity_setup.sh | bash
```
El script muestra un menú para elegir qué componentes instalar.

## 💻 Ejecución local
También puedes clonar este repositorio y ejecutar el instalador de forma local:
```bash
git clone https://github.com/marcogll/mac_vntySet.git
cd mac_vntySet
chmod +x vanity_setup.sh
bash vanity_setup.sh
```
Cada ejecución genera un registro detallado en `.logs/vanity-YYYYmmdd-HHMMSS.log` dentro del repositorio, útil para depurar si algo falla.

## 🧩 Opciones del menú
| Opción | Descripción | Incluye |
|--------|-------------|---------|
| `A`    | Instalación completa (recomendada). | Homebrew + stack Zsh + Docker CLI/Portainer/Lazydocker. |
| `C`    | Solo configura la terminal. | Homebrew + Zsh, Oh My Zsh, Oh My Posh, utilidades CLI. |
| `D`    | Solo herramientas de contenedores. | Homebrew + Docker CLI, Portainer, Lazydocker. |
| `Q`    | Salir. | — |

## 🔧 Detalles de la configuración Zsh
- Copia `~/.zshrc` desde `.zshrc.example` (incluye comentarios en español).
- Instala los plugins necesarios y refresca sus repositorios si ya existen.
- Coloca el tema Catppuccin en `~/.poshthemes` y activa Oh My Posh automáticamente.
- Copia `source ~/.zshrc` al portapapeles para que puedas recargar la shell al finalizar.
- Genera los directorios `~/videos/youtube` y `~/musica/youtube` y define alias listos para descargar con `ytv <url>` (video completo) y `ytm <url>` (solo audio MP3).
- Añade un comando `help` dentro de Zsh que describe el uso de estos alias.
- Cambia la fuente predeterminada de la app Terminal a *MesloLGS Nerd Font* (tamaño 14) para que los iconos de Oh My Posh se vean bien desde el primer arranque.

## 🐳 Stack Docker + Portainer
1. Instala el Docker CLI oficial (`brew install docker docker-buildx docker-compose`) y `lazydocker`.
2. Instala Docker Desktop vía Homebrew Cask y lo abre automáticamente.
3. Espera a que Docker Desktop termine de iniciar (el script consulta `docker info` hasta tener respuesta).
4. Cuando el daemon está listo, despliega Portainer CE publicando `8000` y `9443` (`https://localhost:9443`).

> Si Docker Desktop no termina de arrancar, el instalador lo indicará y deberás abrir la app manualmente antes de volver a elegir la opción `D`.

## ✅ Verificación rápida
- Recargar Zsh: `source ~/.zshrc`
- Reinicia tu Mac después de ejecutar el comando anterior para que la fuente y los servicios se apliquen en todo el sistema.
- Cierra y vuelve a abrir Terminal: la fuente debe ser MesloLGS Nerd Font con los iconos correctos en el prompt.
- Comprobar Oh My Posh: el prompt debe mostrar colores y símbolos; si no, ejecuta `oh-my-posh init zsh --config ~/.poshthemes/catppuccin.omp.json`.
- Verificar Docker: `docker info`
- Confirmar Portainer: abre `https://localhost:9443` en el navegador.
- Lanzar Lazydocker: `lazydocker`
- Probar ZeroTier CLI: `zerotier-cli info`
- Ejecutar una prueba rápida de red: `speedtest-cli`
- Descargar un video de prueba: `ytv https://youtu.be/<ID>`
- Descargar solo audio: `ytm https://youtu.be/<ID>`
- Ver ayuda rápida: ejecuta `help`

## 🧰 Personalización
- Edita `~/.zshrc` para añadir alias o funciones propios; el archivo viene por secciones comentadas.
- Cambia el tema de Oh My Posh apuntando a otro `.omp.json` (guárdalo en `~/.poshthemes`).
- Añade paquetes con `brew install <formula>`; el shell ya tiene Homebrew disponible.

## ❗️ Solución de problemas
- **“command not found: brew”**: ejecuta `eval "$(/opt/homebrew/bin/brew shellenv)"` (o `/usr/local/bin/brew`) y vuelve a correr la opción deseada.
- **Docker no arranca**: abre Docker Desktop y espera a que muestre “Running”; luego ejecuta `docker info` y repite la opción `D`.
- **Oh My Posh sin fuente correcta**: instala Meslo manualmente desde `~/Library/Fonts` o selecciona *Meslo LG S DZ Nerd Font* en tu terminal.
- **Conflictos con un `.zshrc` previo**: el instalador hace backup implícito sobrescribiendo `~/.zshrc`. Asegúrate de versionar tu archivo antes si necesitas conservarlo.

## 🧽 Desinstalación rápida
- Elimina Portainer: `docker stop portainer && docker rm portainer && docker volume rm portainer_data`.
- Borra la config Zsh (opcional): `rm -rf ~/.oh-my-zsh ~/.poshthemes ~/.zshrc`.
- Desinstala apps con Homebrew: `brew uninstall docker docker-buildx docker-compose lazydocker oh-my-posh` y `brew uninstall --cask docker`.

## 📄 Licencia
Distribuido bajo la licencia MIT. Consulta `LICENSE` para más detalles.
