set -e

install_starship() {
    echo "Installing Starship..."
    if ! command -v starship &>/dev/null; then
        curl -sS https://starship.rs/install.sh | sh -s -- -y
    else
        echo "Starship is already installed"
    fi
}

install_neovim() {
    echo "Installing Neovim (AppImage)..."
    if ! command -v nvim &>/dev/null; then
        curl -LO https://github.com/neovim/neovim/releases/latest/download/nvim-linux-x86_64.appimage 
        chmod u+x nvim-linux-x86_64.appimage
        mkdir -p ~/.local/bin
        mv ./nvim-linux-x86_64.appimage ~/.local/bin/nvim
        if ! grep -q 'export PATH="$HOME/.local/bin:$PATH"' ~/.bashrc; then
            echo 'export PATH="$HOME/.local/bin:$PATH"' >> ~/.bashrc
        fi
    else
        echo "Neovim is already installed"
    fi
}


