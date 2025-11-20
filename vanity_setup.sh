#!/usr/bin/env bash

echo "=== Vanity macOS Setup ==="

# -----------------------------
# Helper functions
# -----------------------------
install_if_missing() {
    if ! command -v "$1" >/dev/null 2>&1; then
        echo "[Installing $1]"
        brew install "$1"
    else
        echo "[$1 already installed]"
    fi
}

# -----------------------------
# Ensure ZSH exists
# -----------------------------
if ! command -v zsh >/dev/null 2>&1; then
    echo "[Installing Zsh]"
    brew install zsh
else
    echo "[Zsh already installed]"
fi

# -----------------------------
# Homebrew
# -----------------------------
if ! command -v brew >/dev/null 2>&1; then
    echo "[Installing Homebrew]"
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
else
    echo "[Homebrew already installed]"
fi

# Load brew environment
eval "$(/opt/homebrew/bin/brew shellenv)"

# -----------------------------
# Core packages
# -----------------------------
echo "[Installing core tools]"
install_if_missing curl
install_if_missing wget
install_if_missing git
install_if_missing jq
install_if_missing unzip

# -----------------------------
# Python / Node / Docker
# -----------------------------
echo "[Installing languages & containers]"
install_if_missing python
install_if_missing node
install_if_missing docker
install_if_missing docker-compose

# -----------------------------
# Oh My Zsh
# -----------------------------
if [ ! -d "$HOME/.oh-my-zsh" ]; then
    echo "[Installing Oh My Zsh]"
    RUNZSH=no KEEP_ZSHRC=yes sh -c \
        "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
else
    echo "[Oh My Zsh already installed]"
fi

# -----------------------------
# Zsh plugins
# -----------------------------
echo "[Installing Zsh plugins]"

# Autosuggestions
if [ ! -d "${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/zsh-autosuggestions" ]; then
    git clone https://github.com/zsh-users/zsh-autosuggestions \
      ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/zsh-autosuggestions
fi

# Syntax highlighting
if [ ! -d "${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting" ]; then
    git clone https://github.com/zsh-users/zsh-syntax-highlighting.git \
      ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting
fi

# -----------------------------
# Oh My Posh
# -----------------------------
echo "[Installing Oh My Posh]"
brew install jandedobbeleer/oh-my-posh/oh-my-posh

echo "[Installing Nerd Font]"
oh-my-posh font install Meslo

# Descargar tema Catppuccin
echo "[Downloading Catppuccin theme]"
curl -fsSL \
  https://raw.githubusercontent.com/JanDeDobbeleer/oh-my-posh/main/themes/catppuccin.omp.json \
  -o ~/catppuccin.omp.json

# -----------------------------
# yt-dlp + ffmpeg
# -----------------------------
echo "[Installing yt-dlp + ffmpeg]"
install_if_missing yt-dlp
install_if_missing ffmpeg

# Carpeta de descargas
mkdir -p ~/Downloads/youtube/video
mkdir -p ~/Downloads/youtube/audio

# -----------------------------
# Download .zshrc (CUSTOMIZE URL)
# -----------------------------
echo "[Downloading .zshrc Vanity]"
curl -fsSL "https://raw.githubusercontent.com/vanity/mac-setup/main/zshrc" \
    -o ~/.zshrc

# -----------------------------
# Add yt aliases
# -----------------------------
if ! grep -q "alias ytv=" ~/.zshrc; then
cat << 'EOF' >> ~/.zshrc

# Vanity YouTube Download Aliases
alias ytv='yt-dlp -o "~/Downloads/youtube/video/%(title)s.%(ext)s"'
alias ytm='yt-dlp -x --audio-format mp3 -o "~/Downloads/youtube/audio/%(title)s.%(ext)s"'
EOF
fi

# -----------------------------
# Oh My Posh init
# -----------------------------
if ! grep -q "oh-my-posh init zsh" ~/.zshrc; then
cat << 'EOF' >> ~/.zshrc

# Oh My Posh – Catppuccin
eval "$(oh-my-posh init zsh --config ~/catppuccin.omp.json)"
EOF
fi

# -----------------------------
# Default shell
# -----------------------------
echo "[Setting Zsh as default shell]"
chsh -s "$(which zsh)"

echo "=== Installation Complete — restart your terminal ==="
