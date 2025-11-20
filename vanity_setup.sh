#!/usr/bin/env bash
set -e

# ==============================================
# HEADER
# ==============================================
header() {
  echo ""
  echo "=============================================="
  echo "                V A N I T Y  S H E L L"
  echo "            macOS Development Installer"
  echo "=============================================="
  echo ""
}

# ==============================================
# PROGRESO VISUAL
# ==============================================
progress() {
  local task="$1"
  echo "→ $task"
  for i in 10 25 40 55 70 85 100; do
    printf "   [%3s%%]\r" "$i"
    sleep 0.06
  done
  printf "   [100%%] ✓ Completado\n\n"
}

# ==============================================
# INSTALACIÓN REAL
# ==============================================
install_everything() {

  # ------------------------------------------------
  # Homebrew
  # ------------------------------------------------
  progress "Instalando Homebrew"
  if ! command -v brew >/dev/null 2>&1; then
      NONINTERACTIVE=1 /bin/bash -c \
        "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
      echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' >> ~/.zprofile
      eval "$(/opt/homebrew/bin/brew shellenv)"
  fi

  brew update

  # ------------------------------------------------
  # Paquetes base
  # ------------------------------------------------
  progress "Instalando paquetes base"
  brew install zsh curl wget git xclip yq jq

  # ------------------------------------------------
  # Oh My Zsh
  # ------------------------------------------------
  progress "Instalando Oh My Zsh"
  if [ ! -d "$HOME/.oh-my-zsh" ]; then
      RUNZSH=no CHSH=no KEEP_ZSHRC=yes \
        sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
  fi

  # ------------------------------------------------
  # Plugins ZSH
  # ------------------------------------------------
  progress "Instalando plugins ZSH"
  mkdir -p ~/.oh-my-zsh/custom/plugins

  repos=(
    "zsh-users/zsh-autosuggestions"
    "zsh-users/zsh-syntax-highlighting"
    "zsh-users/zsh-completions"
  )

  for r in "${repos[@]}"; do
      folder=$(basename "$r")
      [ ! -d "$HOME/.oh-my-zsh/custom/plugins/$folder" ] && \
        git clone https://github.com/$r ~/.oh-my-zsh/custom/plugins/$folder
  done

  # ------------------------------------------------
  # Oh My Posh + tema + fuente
  # ------------------------------------------------
  progress "Instalando Oh My Posh y tema Catppuccin"
  brew install jandedobbeleer/oh-my-posh/oh-my-posh
  mkdir -p ~/.poshthemes
  curl -fsSL \
    https://raw.githubusercontent.com/JanDeDobbeleer/oh-my-posh/main/themes/catppuccin.omp.json \
    -o ~/.poshthemes/catppuccin.omp.json

  oh-my-posh font install meslo

  # ------------------------------------------------
  # Descargar tu archivo .zshrc
  # ------------------------------------------------
  progress "Descargando archivo .zshrc VanityOS"
  curl -fsSL \
    https://raw.githubusercontent.com/marcogll/mac_vntySet/refs/heads/main/.zshrc.example \
    -o ~/.zshrc

  # ------------------------------------------------
  # Python, Node, yt-dlp, Docker, LazyDocker
  # ------------------------------------------------
  progress "Instalando Python, Node, yt-dlp y LazyDocker"
  brew install python node yt-dlp lazydocker

  # ------------------------------------------------
  # Docker Desktop
  # ------------------------------------------------
  progress "Instalando Docker Desktop (CLI + Compose)"
  brew install --cask docker

  # ------------------------------------------------
  # Portainer (Docker)
  # ------------------------------------------------
  progress "Configurando Portainer CE"
  docker volume create portainer_data || true
  docker stop portainer >/dev/null 2>&1 || true
  docker rm portainer >/dev/null 2>&1 || true

  docker run -d \
    -p 8000:8000 -p 9443:9443 \
    --name=portainer \
    --restart=always \
    -v /var/run/docker.sock:/var/run/docker.sock \
    -v portainer_data:/data \
    portainer/portainer-ce:latest

  # ------------------------------------------------
  # Copiar "source ~/.zshrc" al portapapeles
  # ------------------------------------------------
  echo "source ~/.zshrc" | pbcopy
  echo ""
  echo "La configuración está lista."
  echo "Pega en tu terminal:"
  echo ""
  echo "   source ~/.zshrc"
  echo ""
  echo "(Ya está copiado en tu portapapeles)"
}

# ==============================================
# MENU
# ==============================================
menu() {
  header

  echo "Selecciona una opción (ENTER = A):"
  echo ""
  echo "   A) Instalar TODO (recomendado)"
  echo "   1) Instalar Homebrew"
  echo "   2) Instalar ZSH + plugins"
  echo "   3) Instalar Oh My Posh + tema"
  echo "   4) Instalar Python + Node"
  echo "   5) Instalar Docker + Portainer + LazyDocker"
  echo "   6) Instalar yt-dlp + aliases"
  echo "   0) Salir"
  echo ""

  read -rp "Opción [A]: " opt
  opt="${opt:-A}"

  echo ""

  case "$opt" in
    A|a) install_everything ;;
    0) echo "Saliendo…"; exit 0 ;;
    *)
      echo "Modo individual aún no habilitado."
      sleep 1
      menu
      ;;
  esac
}

menu
