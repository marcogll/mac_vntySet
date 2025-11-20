#!/usr/bin/env bash
set -e

# ────────────────────────────────────────────────
# ASCII ART VANITY OS SHELL
# ────────────────────────────────────────────────
printf "\n"
printf "██╗   ██╗ █████╗ ███╗   ██╗██╗███╗   ██╗██╗   ██╗     ██████╗ ███████╗\n"
printf "██║   ██║██╔══██╗████╗  ██║██║████╗  ██║██║   ██║    ██╔════╝ ██╔════╝\n"
printf "██║   ██║███████║██╔██╗ ██║██║██╔██╗ ██║██║   ██║    ██║  ███╗█████╗  \n"
printf "╚██╗ ██╔╝██╔══██║██║╚██╗██║██║██║╚██╗██║██║   ██║    ██║   ██║██╔══╝  \n"
printf " ╚████╔╝ ██║  ██║██║ ╚████║██║██║ ╚████║╚██████╔╝    ╚██████╔╝███████╗\n"
printf "  ╚═══╝  ╚═╝  ╚═╝╚═╝  ╚═══╝╚═╝╚═╝  ╚═══╝ ╚═════╝      ╚═════╝ ╚══════╝\n"
printf "                 Vanity OS Shell Installer (macOS)\n\n"

# ────────────────────────────────────────────────
# Homebrew
# ────────────────────────────────────────────────
if ! command -v brew >/dev/null 2>&1; then
    echo "Instalando Homebrew…"
    NONINTERACTIVE=1 /bin/bash -c \
        "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' >> ~/.zprofile
    eval "$(/opt/homebrew/bin/brew shellenv)"
else
    echo "Homebrew ya está instalado."
fi

echo "Actualizando Homebrew…"
brew update

# ────────────────────────────────────────────────
# Instalando paquetes base
# ────────────────────────────────────────────────
brew install zsh curl wget git xclip yq jq

# ────────────────────────────────────────────────
# Oh My Zsh
# ────────────────────────────────────────────────
if [ ! -d "$HOME/.oh-my-zsh" ]; then
    echo "Instalando Oh My Zsh…"
    RUNZSH=no CHSH=no KEEP_ZSHRC=yes \
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
fi

# ────────────────────────────────────────────────
# Plugins de ZSH
# ────────────────────────────────────────────────
mkdir -p ~/.oh-my-zsh/custom/plugins

repos=(
  "zsh-users/zsh-autosuggestions"
  "zsh-users/zsh-syntax-highlighting"
  "zsh-users/zsh-completions"
)

for r in "${repos[@]}"; do
    folder=$(basename "$r")
    if [ ! -d "$HOME/.oh-my-zsh/custom/plugins/$folder" ]; then
        git clone https://github.com/$r ~/.oh-my-zsh/custom/plugins/$folder
    fi
done

# ────────────────────────────────────────────────
# Instalación Oh My Posh + tema + fuentes
# ────────────────────────────────────────────────
brew install jandedobbeleer/oh-my-posh/oh-my-posh

mkdir -p ~/.poshthemes
curl -fsSL \
  https://raw.githubusercontent.com/JanDeDobbeleer/oh-my-posh/main/themes/catppuccin.omp.json \
  -o ~/.poshthemes/catppuccin.omp.json

# fuente recomendada
oh-my-posh font install meslo

# ────────────────────────────────────────────────
# Descargar tu .zshrc.example
# ────────────────────────────────────────────────
echo "Descargando .zshrc.example…"
curl -fsSL https://raw.githubusercontent.com/marcogll/mac_vntySet/refs/heads/main/.zshrc.example \
  -o ~/.zshrc

# ────────────────────────────────────────────────
# Python, Node, Docker, Lazydocker
# ────────────────────────────────────────────────
brew install python node lazydocker

# Docker Desktop CLI + Compose
brew install --cask docker

# ────────────────────────────────────────────────
# Portainer (docker)
# ────────────────────────────────────────────────
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

# ────────────────────────────────────────────────
# Copiar "source ~/.zshrc" al portapapeles
# ────────────────────────────────────────────────
echo "source ~/.zshrc" | pbcopy

printf "\nListo.\n"
printf "Pega y ejecuta en tu terminal para activar la configuración:\n"
printf "\n    source ~/.zshrc\n\n"
printf "(Ya lo tienes en el portapapeles, solo pega con Cmd+V)\n\n"
