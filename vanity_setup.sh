#!/usr/bin/env bash

set -e

ZSHRC_URL="https://raw.githubusercontent.com/marcogll/mac_vntySet/refs/heads/main/.zshrc.example"
DOWNLOAD_DIR="$HOME/downloads/youtube"
VIDEO_DIR="$DOWNLOAD_DIR/video"
AUDIO_DIR="$DOWNLOAD_DIR/audio"

echo "[+] Verificando Homebrew..."
if ! command -v brew &>/dev/null; then
    echo "[+] Instalando Homebrew..."
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
fi

eval "$(/opt/homebrew/bin/brew shellenv 2>/dev/null)"

echo "[+] Instalando paquetes base (zsh, curl, wget, python, node, docker, yt-dlp)..."
brew install zsh curl wget python node docker docker-compose yt-dlp

echo "[+] Instalando Oh My Zsh..."
if [[ ! -d "$HOME/.oh-my-zsh" ]]; then
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
fi

echo "[+] Instalando plugins de Zsh..."
brew install zsh-autosuggestions zsh-syntax-highlighting

echo "[+] Instalando Oh My Posh..."
brew install jandedobbeleer/oh-my-posh/oh-my-posh

echo "[+] Instalando fuente Nerd Font para el tema..."
oh-my-posh font install Meslo

echo "[+] Descargando tema Catppuccin para Oh My Posh..."
mkdir -p ~/.poshthemes
curl -fsSL \
  https://raw.githubusercontent.com/JanDeDobbeleer/oh-my-posh/main/themes/catppuccin.omp.json \
  -o ~/.poshthemes/catppuccin.omp.json

chmod +r ~/.poshthemes/*.json

echo "[+] Descargando tu .zshrc desde GitHub..."
curl -fsSL "$ZSHRC_URL" -o ~/.zshrc

echo "[+] Creando carpetas para yt-dlp..."
mkdir -p "$VIDEO_DIR" "$AUDIO_DIR"

echo "[+] Agregando alias ytv / ytm / help..."
cat <<'EOF' >> ~/.zshrc

# --- Vanity additions (auto) ---

alias ytv='yt-dlp -o "'"$VIDEO_DIR"'/%(title)s.%(ext)s"'
alias ytm='yt-dlp -x --audio-format mp3 -o "'"$AUDIO_DIR"'/%(title)s.%(ext)s"'

alias help="echo '\
Comandos disponibles:
  ytv URL   - Descarga video en $VIDEO_DIR
  ytm URL   - Descarga música (MP3) en $AUDIO_DIR
  cls       - Limpiar pantalla
  brew      - Gestor de paquetes
  python, node, docker, compose disponibles tras instalación
'"

# Plugins Zsh
source /opt/homebrew/share/zsh-autosuggestions/zsh-autosuggestions.zsh
source /opt/homebrew/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh

# Oh My Posh
eval \"$(oh-my-posh init zsh --config ~/.poshthemes/catppuccin.omp.json)\"

# ---
EOF

echo "[+] Aplicando configuración..."
exec zsh
