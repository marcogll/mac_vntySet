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

install_cli_dependencies() {
  echo "Instalando herramientas base de desarrollo…"
  brew install zsh curl wget git jq yq node python go direnv yt-dlp ffmpeg

  echo "Instalando Oh My Posh y fuentes Nerd Font…"
  brew tap homebrew/cask-fonts >/dev/null 2>&1 || true
  brew install --cask font-meslo-lg-nerd-font
  brew install jandedobbeleer/oh-my-posh/oh-my-posh
}

setup_media_dirs() {
  mkdir -p "$HOME/videos/youtube" "$HOME/musica/youtube"
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
    else
      git clone "https://github.com/${repo}.git" "$destination"
    fi
  done
}

install_zsh_config() {
  install_cli_dependencies
  install_oh_my_zsh
  setup_media_dirs

  echo "Configurando Oh My Posh…"
  mkdir -p "$HOME/.poshthemes"
  curl -fsSL "$POSH_THEME_URL" -o "$POSH_THEME_PATH"

  echo "Descargando .zshrc de Vanity Shell…"
  if ! curl -fsSL "$ZSHRC_URL" -o "$HOME/.zshrc"; then
    echo "No se pudo descargar la configuración de ZSH." >&2
    exit 1
  fi

  if command -v pbcopy >/dev/null 2>&1; then
    echo "source ~/.zshrc" | pbcopy
    echo "El comando 'source ~/.zshrc' fue copiado al portapapeles."
  fi

  echo "Configuración de ZSH instalada correctamente."
}

ensure_docker_daemon() {
  if ! command -v docker >/dev/null 2>&1; then
    echo "El CLI de Docker no está disponible todavía." >&2
    return 1
  fi

  if docker info >/dev/null 2>&1; then
    return 0
  fi

  if command -v open >/dev/null 2>&1; then
    echo "Iniciando Docker Desktop…"
    open -g -a Docker >/dev/null 2>&1 || true
  else
    echo "Abre Docker Desktop manualmente para continuar." >&2
  fi

  for _ in {1..20}; do
    sleep 6
    if docker info >/dev/null 2>&1; then
      return 0
    fi
  done

  echo "Docker Desktop no está listo. Abre la aplicación y vuelve a ejecutar la opción D." >&2
  return 1
}

install_docker_stack() {
  echo "Instalando Docker Desktop…"
  brew install --cask docker

  echo "Instalando Lazydocker…"
  brew install lazydocker

  if ! ensure_docker_daemon; then
    echo "Se omitió Portainer porque Docker no está operativo."
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

main_menu() {
  echo "Selecciona una opción:"
  echo " A) Instalar TODO (recomendado)"
  echo " C) Instalar solo configuración ZSH"
  echo " D) Instalar Docker + Portainer + Lazydocker"
  echo " Q) Salir"
  echo ""
  read -r -p "Opción [A/C/D/Q]: " choice
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
