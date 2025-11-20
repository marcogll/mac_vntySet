#!/usr/bin/env bash

set -e

clear
echo ""
echo "=============================================="
echo "              V A N I T Y  S H E L L"
echo "          macOS Development Installer"
echo "=============================================="
echo ""

echo "Selecciona una opción:"
echo " A) Instalar TODO (recomendado)"
echo " C) Instalar solo configuración ZSH"
echo " D) Instalar Docker + Portainer + Lazydocker"
echo " Q) Salir"
echo ""
read -p "Opción [A/C/D/Q]: " choice
choice=${choice:-A}


install_homebrew() {
    if ! command -v brew >/dev/null 2>&1; then
        echo "Instalando Homebrew…"
        NONINTERACTIVE=1 /bin/bash -c \
            "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
        echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' >> ~/.zprofile
        eval "$(/opt/homebrew/bin/brew shellenv)"
    else
        echo "Homebrew ya está instalado."
    fi

    brew update
}

install_zsh_config() {
    echo "Instalando ZSH base…"
    brew install zsh curl wget git yq jq xclip node python

    echo "Instalando Oh My Zsh…"
    if [ ! -d "$HOME/.oh-my-zsh" ]; then
        RUNZSH=no CHSH=no KEEP_ZSHRC=yes \
        sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
    fi

    echo "Instalando plugins…"
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

    echo "Instalando Oh My Posh…"
    brew install jandedobbeleer/oh-my-posh/oh-my-posh

    mkdir -p ~/.poshthemes
    curl -fsSL \
      https://raw.githubusercontent.com/JanDeDobbeleer/oh-my-posh/main/themes/catppuccin.omp.json \
      -o ~/.poshthemes/catppuccin.omp.json

    oh-my-posh font install meslo

    echo "Descargando tu .zshrc.example…"
    curl -fsSL https://raw.githubusercontent.com/marcogll/mac_vntySet/main/.zshrc.example \
      -o ~/.zshrc

    echo "source ~/.zshrc" | pbcopy
    echo ""
    echo "Tu configuración ZSH está instalada."
    echo "El comando 'source ~/.zshrc' ya está copiado al portapapeles."
    echo ""
}

install_docker_stack() {
    echo "Instalando Docker Desktop…"
    brew install --cask docker

    echo "Instalando Lazydocker…"
    brew install lazydocker

    echo "Instalando Portainer…"
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
}


case "$choice" in
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
        echo "Opción inválida."
        exit 1
        ;;
esac


echo ""
echo "=============================================="
echo " Instalación completada."
echo "=============================================="
echo ""
