#!/usr/bin/env bash

set -euo pipefail

SCRIPT_PATH=${BASH_SOURCE[0]:-$0}
if [[ "$SCRIPT_PATH" == "bash" || "$SCRIPT_PATH" == "-bash" ]]; then
  SCRIPT_DIR="$PWD"
else
  SCRIPT_DIR=$(cd "$(dirname "$SCRIPT_PATH")" >/dev/null 2>&1 && pwd -P) || SCRIPT_DIR="$PWD"
fi

LOG_DIR="$SCRIPT_DIR/.logs"
mkdir -p "$LOG_DIR"
LOG_FILE="$LOG_DIR/vanity-$(date +%Y%m%d-%H%M%S).log"
touch "$LOG_FILE"
exec > >(tee -a "$LOG_FILE") 2>&1
echo "Log de instalación: $LOG_FILE"

readonly POSH_THEME_URL="https://raw.githubusercontent.com/JanDeDobbeleer/oh-my-posh/main/themes/catppuccin.omp.json"
readonly ZSHRC_URL="https://raw.githubusercontent.com/marcogll/mac_vntySet/main/.zshrc.example"
readonly POSH_THEME_PATH="$HOME/.poshthemes/catppuccin.omp.json"

if [[ "$(uname -s)" != "Darwin" ]]; then
  echo "Este instalador solo funciona en macOS." >&2
  exit 1
fi

trap 'echo -e "\nSe produjo un error. Revisa los mensajes anteriores para más detalles." >&2' ERR

BREW_BIN=""

retry_command() {
  local -r max_attempts=3
  local attempt=1
  local -a cmd=("$@")

  until "${cmd[@]}"; do
    if (( attempt >= max_attempts )); then
      return 1
    fi
    sleep "$((attempt * 2))"
    attempt=$((attempt + 1))
  done
  return 0
}

readonly GITHUB_CLONE_PREFIXES=(
  "https://github.com/"
  "https://ghproxy.com/https://github.com/"
  "https://hub.fastgit.org/"
  "https://github.com.cnpmjs.org/"
)

readonly ARCHIVE_TEMPLATES=(
  "https://codeload.github.com/%s/tar.gz/HEAD"
  "https://ghproxy.com/https://codeload.github.com/%s/tar.gz/HEAD"
  "https://github.com/%s/archive/HEAD.tar.gz"
  "https://ghproxy.com/https://github.com/%s/archive/HEAD.tar.gz"
)

clone_plugin_repo() {
  local repo="$1"
  local destination="$2"

  if ! command -v git >/dev/null 2>&1; then
    return 1
  fi

  for prefix in "${GITHUB_CLONE_PREFIXES[@]}"; do
    rm -rf "$destination"
    local url="${prefix}${repo}.git"
    if retry_command git clone "$url" "$destination"; then
      return 0
    fi
  done

  return 1
}

download_plugin_archive() {
  local repo="$1"
  local destination="$2"

  if ! command -v curl >/dev/null 2>&1; then
    return 1
  fi

  rm -rf "$destination"
  for template in "${ARCHIVE_TEMPLATES[@]}"; do
    mkdir -p "$destination"
    local archive_url
    archive_url=$(printf "$template" "$repo")
    if curl -fsSL "$archive_url" | tar -xzf - -C "$destination" --strip-components=1 >/dev/null 2>&1; then
      return 0
    fi
    rm -rf "$destination"
  done

  return 1
}

ensure_brew_shellenv() {
  if command -v brew >/dev/null 2>&1; then
    BREW_BIN=$(command -v brew)
    eval "$("$BREW_BIN" shellenv)"
    return
  fi

  for candidate in /opt/homebrew/bin/brew /usr/local/bin/brew; do
    if [ -x "$candidate" ]; then
      BREW_BIN="$candidate"
      eval "$("$BREW_BIN" shellenv)"
      return
    fi
  done
}

install_homebrew() {
  ensure_xcode_clt

  if [ -z "$BREW_BIN" ] && [ ! -x /opt/homebrew/bin/brew ] && [ ! -x /usr/local/bin/brew ]; then
    echo "Instalando Homebrew…"
    NONINTERACTIVE=1 /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
  fi

  ensure_brew_shellenv

  if [ -n "$BREW_BIN" ]; then
    local shell_line="eval \"\$($BREW_BIN shellenv)\""
    if ! grep -qsF "$shell_line" "$HOME/.zprofile" 2>/dev/null; then
      printf '%s\n' "$shell_line" >> "$HOME/.zprofile"
    fi
  fi

  brew update
}

brew_ensure_formula() {
  local formula="$1"
  if brew list --formula "$formula" >/dev/null 2>&1; then
    if [[ "$formula" == "yt-dlp" ]]; then
      echo "➜ yt-dlp ya está instalado. Actualizando a la última versión…"
      brew upgrade yt-dlp
    else
      echo "✔︎ ${formula} ya está instalado. Omitiendo."
    fi
    return
  fi

  echo "➜ Instalando ${formula}…"
  brew install "$formula"
}

brew_ensure_cask() {
  local cask="$1"
  if brew list --cask "$cask" >/dev/null 2>&1; then
    echo "✔︎ ${cask} ya está instalado. Omitiendo."
    return
  fi

  echo "➜ Instalando ${cask}…"
  local output
  if ! output=$(brew install --cask "$cask" 2>&1); then
    if [[ "$output" == *"already a Font at"* ]]; then
      echo "✔︎ La fuente de ${cask} ya existe. Omitiendo."
    else
      echo "$output" >&2
      echo "Error al instalar ${cask}." >&2
      return 1
    fi
  fi
}

install_cli_dependencies() {
  echo "Instalando herramientas base de desarrollo…"
  local formulas=(
    zsh
    curl
    wget
    git
    jq
    yq
    node
    python
    go
    direnv
    yt-dlp
    ffmpeg
    speedtest-cli
    jandedobbeleer/oh-my-posh/oh-my-posh
  )

  for formula in "${formulas[@]}"; do
    brew_ensure_formula "$formula"
  done

  echo "Instalando Oh My Posh y fuentes Nerd Font…"
  brew tap homebrew/cask-fonts >/dev/null 2>&1 || true
  brew_ensure_cask font-meslo-lg-nerd-font
  brew_ensure_cask zerotier-one
}

setup_media_dirs() {
  mkdir -p "$HOME/Movies/Youtube" "$HOME/Music/Youtube"
}

configure_terminal_font() {
  if ! command -v osascript >/dev/null 2>&1; then
    return
  fi

  local font_name font_size
  font_name="MesloLGS Nerd Font"
  font_size=14

  echo "Configurando Terminal para usar la fuente $font_name…"
  osascript >/dev/null 2>&1 \
    -e "tell application \"Terminal\"" \
    -e "  try" \
    -e "    set font name of default settings to \"${font_name}\"" \
    -e "    set font size of default settings to ${font_size}" \
    -e "    set font name of startup settings to \"${font_name}\"" \
    -e "    set font size of startup settings to ${font_size}" \
    -e "  end try" \
    -e "end tell"
}

install_oh_my_zsh() {
  echo "Instalando Oh My Zsh y plugins…"
  if [ ! -d "$HOME/.oh-my-zsh" ]; then
    RUNZSH=no CHSH=no KEEP_ZSHRC=yes \
      sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
  fi

  mkdir -p "$HOME/.oh-my-zsh/custom/plugins"

  local repos=(
    "zsh-users/zsh-autosuggestions"
    "zsh-users/zsh-syntax-highlighting"
    "zsh-users/zsh-completions"
  )

  for repo in "${repos[@]}"; do
    local destination="$HOME/.oh-my-zsh/custom/plugins/$(basename "$repo")"
    if [ -d "$destination/.git" ]; then
      git -C "$destination" pull --ff-only >/dev/null 2>&1 || true
      continue
    fi

    if clone_plugin_repo "$repo" "$destination"; then
      continue
    fi

    echo "No se pudo clonar https://github.com/${repo}.git con git, intentando descargar el archivo..." >&2
    if download_plugin_archive "$repo" "$destination"; then
      continue
    fi

    echo "Advertencia: no se pudo instalar ${repo}. Verifica la conexión e inténtalo de nuevo." >&2
  done
}

install_zsh_config() {
  install_cli_dependencies
  install_oh_my_zsh
  setup_media_dirs
  configure_terminal_font

  echo "Configurando Oh My Posh…"
  mkdir -p "$HOME/.poshthemes"
  curl -fsSL "$POSH_THEME_URL" -o "$POSH_THEME_PATH"

  echo "Descargando y configurando .zshrc de Vanity Shell…"
  local zshrc_content
  if ! zshrc_content=$(curl -fsSL "$ZSHRC_URL"); then
    echo "No se pudo descargar la configuración de ZSH." >&2
    exit 1
  fi

  local brew_init_line=""
  if [ -n "$BREW_BIN" ]; then
    # Esta línea se añade al principio para garantizar que el PATH de Homebrew
    # se configure ANTES de que Oh My Zsh intente cargar plugins como 'docker'.
    brew_init_line="eval \"\$($BREW_BIN shellenv)\""
  fi

  # Combina la inicialización de Homebrew con el contenido descargado
  echo -e "${brew_init_line}\n\n${zshrc_content}" > "$HOME/.zshrc"

  if command -v pbcopy >/dev/null 2>&1; then
    echo "source ~/.zshrc" | pbcopy
    echo "El comando 'source ~/.zshrc' fue copiado al portapapeles."
  fi

  echo "Configuración de ZSH instalada correctamente."
}

ensure_docker_daemon() {
  if ! command -v docker >/dev/null 2>&1; then
    echo "El CLI de Docker no está disponible." >&2
    return 1
  fi

  if docker info >/dev/null 2>&1; then
    return 0
  fi

  echo "No se detectó un demonio de Docker en ejecución." >&2
  echo "Asegúrate de que Docker Desktop, OrbStack u otro daemon remoto esté activo." >&2
  return 1
}

wait_for_docker_desktop() {
  local attempts=0
  local max_attempts=40
  local delay=5

  echo "Esperando a que Docker Desktop termine de iniciar…"
  while (( attempts < max_attempts )); do
    if docker info >/dev/null 2>&1; then
      echo "Docker Desktop está operativo."
      return 0
    fi
    sleep "$delay"
    attempts=$((attempts + 1))
  done

  echo "Docker Desktop no respondió después de $((max_attempts * delay)) segundos." >&2
  return 1
}

install_docker_stack() {
  echo "Instalando Docker CLI y utilidades…"
  brew install docker docker-buildx docker-compose lazydocker
  brew install --cask docker

  echo "Abriendo Docker Desktop…"
  open -gj -a Docker || open -a Docker || true

  if ! wait_for_docker_desktop; then
    echo "Se omitió Portainer porque Docker Desktop no está listo." >&2
    echo "Abre Docker Desktop manualmente y vuelve a ejecutar la opción D." >&2
    return
  fi

  echo "Desplegando Portainer…"
  docker volume create portainer_data >/dev/null 2>&1 || true
  docker stop portainer >/dev/null 2>&1 || true
  docker rm portainer >/dev/null 2>&1 || true

  docker run -d \
    -p 8000:8000 -p 9443:9443 \
    --name=portainer \
    --restart=always \
    -v /var/run/docker.sock:/var/run/docker.sock \
    -v portainer_data:/data \
    portainer/portainer-ce:latest >/dev/null
}

update_packages() {
  echo "Actualizando la lista de paquetes de Homebrew…"
  install_homebrew
  echo "Actualizando todos los paquetes de Homebrew instalados…"
  brew upgrade
  echo "Todos los paquetes han sido actualizados."
}

ensure_xcode_clt() {
  if xcode-select -p >/dev/null 2>&1; then
    return
  fi

  echo "Instalando Xcode Command Line Tools…"
  echo "macOS abrirá un diálogo gráfico; acepta la instalación para continuar."

  if ! /usr/bin/xcode-select --install >/dev/null 2>&1; then
    if xcode-select -p >/dev/null 2>&1; then
      return
    fi
    echo "No se pudo iniciar la instalación automática. Ejecuta 'xcode-select --install' manualmente y vuelve a intentarlo." >&2
    exit 1
  fi

  wait_for_enter "Una vez que la instalación gráfica termine, presiona Enter para continuar… "

  local attempts=0
  local max_attempts=60
  while ! xcode-select -p >/dev/null 2>&1; do
    sleep 5
    attempts=$((attempts + 1))
    if (( attempts >= max_attempts )); then
      echo "No se detectó la instalación de las Xcode Command Line Tools tras varios intentos." >&2
      echo "Instálalas manualmente con 'xcode-select --install' y vuelve a ejecutar este script." >&2
      exit 1
    fi
  done

  echo "Xcode Command Line Tools instaladas correctamente."
}

wait_for_enter() {
  local prompt="$1"

  if [ -t 0 ]; then
    read -r -p "$prompt" _
    printf "\n"
    return 0
  fi

  if [ -r /dev/tty ]; then
    printf "%s" "$prompt" > /dev/tty
    read -r _ < /dev/tty
    printf "\n"
    return 0
  fi

  printf "%s\n" "$prompt"
  return 1
}

read_menu_choice() {
  local prompt="$1"

  if [ -t 0 ]; then
    if read -r -p "$prompt" REPLY; then
      printf "\n"
      return 0
    fi
    printf "\n"
    return 1
  fi

  if [ -r /dev/tty ]; then
    printf "%s" "$prompt" > /dev/tty
    if read -r REPLY < /dev/tty; then
      printf "\n"
      return 0
    fi
  fi

  printf "\n"
  return 1
}

main_menu() {
  echo "Selecciona una opción:"
  echo " A) Instalar TODO (recomendado)"
  echo " C) Instalar solo configuración ZSH"
  echo " D) Instalar Docker + Portainer + Lazydocker"
  echo " P) Actualizar paquetes Homebrew"
  echo " U) Actualizar componentes instalados"
  echo " Q) Salir"
  echo ""
  local choice=""
  if read_menu_choice "Opción [A/C/D/P/U/Q]: "; then
    choice="$REPLY"
  else
    echo "No se detecta una entrada interactiva; se seleccionará la opción 'A' por defecto."
    choice="A"
  fi
  echo ""
  case "${choice:-A}" in
    A|a)
      install_homebrew
      install_zsh_config
      install_docker_stack
      ;;
    C|c)
      install_homebrew
      install_zsh_config
      ;;
    D|d)
      install_homebrew
      install_docker_stack
      ;;
    P|p)
      update_packages
      ;;
    U|u)
      echo "Actualizando la instalación existente…"
      install_homebrew
      install_zsh_config
      install_docker_stack
      ;;
    Q|q)
      echo "Saliendo…"
      exit 0
      ;;
    *)
      echo "Opción inválida." >&2
      exit 1
      ;;
  esac
}

clear
cat <<'BANNER'
==============================================
              V A N I T Y  S H E L L
          macOS Development Installer
==============================================
BANNER

echo ""
main_menu
echo "=============================================="
echo " Instalación completada."
echo "=============================================="
echo ""
echo "Para aplicar la configuración ejecuta ahora:"
echo "source ~/.zshrc"
echo ""
wait_for_enter "Presiona Enter una vez hayas ejecutado el comando anterior en tu terminal… "
echo "Reinicia tu Mac para asegurarte de que todas las herramientas queden listas para el próximo arranque."
echo "Vanity CLI | 'help' sirve para ver los comandos."
