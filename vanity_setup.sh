#!/usr/bin/env bash

set -e

echo ">>> Actualizando Homebrew / instalando si no existe..."
if ! command -v brew &> /dev/null; then
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
fi

brew update

#######################################
# ZSH + OH-MY-ZSH + PLUGINS + OMP
#######################################

echo ">>> Instalando Zsh..."
brew install zsh

echo ">>> Instalando wget y curl..."
brew install wget curl

echo ">>> Instalando Oh My Zsh..."
if [ ! -d "$HOME/.oh-my-zsh" ]; then
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
fi

echo ">>> Instalando plugins zsh..."
brew install zsh-autosuggestions zsh-syntax-highlighting zsh-history-substring-search

echo ">>> Instalando Oh My Posh..."
brew install jandedobbeleer/oh-my-posh/oh-my-posh

echo ">>> Instalando fuente de Oh My Posh..."
oh-my-posh font install Meslo

echo ">>> Descargando tema Catppuccin para OMP..."
mkdir -p ~/.poshthemes
wget -O ~/.poshthemes/catppuccin.omp.json \
    https://raw.githubusercontent.com/JanDeDobbeleer/oh-my-posh/main/themes/catppuccin.omp.json

#######################################
# Python + Node
#######################################

echo ">>> Instalando Python..."
brew install python

echo ">>> Instalando Node..."
brew install node

#######################################
# yt-dlp + alias
#######################################

echo ">>> Instalando yt-dlp..."
brew install yt-dlp ffmpeg

# Crear carpetas
mkdir -p ~/downloads/youtube/video
mkdir -p ~/downloads/youtube/audio

#######################################
# LazyDocker
#######################################

echo ">>> Instalando LazyDocker..."
brew install jesseduffield/lazydocker/lazydocker

#######################################
# Docker CLI + Compose + Portainer
#######################################

echo ">>> Instalando Docker CLI + Docker Compose..."
brew install docker docker-compose

echo ">>> Ejecutando Portainer..."
docker volume create portainer_data

docker run -d \
  -p 8000:8000 \
  -p 9443:9443 \
  --name portainer \
  --restart=always \
  -v /var/run/docker.sock:/var/run/docker.sock \
  -v portainer_data:/data \
  portainer/portainer-ce:latest

#######################################
# Descargar .zshrc custom desde tu repo
#######################################

echo ">>> Descargando tu .zshrc personalizado..."
wget -O ~/.zshrc \
  https://raw.githubusercontent.com/marcogll/mac_vntySet/refs/heads/main/.zshrc.example

#######################################
# Agregar Aliases y ajustes extra
#######################################

cat <<'EOF' >> ~/.zshrc

# -------------------------
# VANITY CUSTOM ALIASES
# -------------------------

alias cls="clear"

# yt-dlp video
alias ytv='yt-dlp -f "bestvideo+bestaudio" -o "~/downloads/youtube/video/%(title)s.%(ext)s"'

# yt-dlp música (mp3)
alias ytm='yt-dlp -x --audio-format mp3 -o "~/downloads/youtube/audio/%(title)s.%(ext)s"'

# LazyDocker
alias lzd="lazydocker"

# Docker compose corto
alias dcu="docker compose up -d"
alias dcd="docker compose down"

# Help command
alias vanity-help="echo '
Comandos disponibles:
    ytv URL     → Descargar video en ~/downloads/youtube/video
    ytm URL     → Descargar audio/mp3 en ~/downloads/youtube/audio
    lzd         → Abrir LazyDocker
    dcu         → docker compose up -d
    dcd         → docker compose down
    cls         → clear
'"

# ZSH plugins
source /opt/homebrew/share/zsh-autosuggestions/zsh-autosuggestions.zsh
source /opt/homebrew/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
source /opt/homebrew/share/zsh-history-substring-search/zsh-history-substring-search.zsh

# Oh My Posh prompt
eval "$(oh-my-posh init zsh --config ~/.poshthemes/catppuccin.omp.json)"

EOF

echo ">>> Instalación completa. Reinicia la terminal."
