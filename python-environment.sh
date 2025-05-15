echo "Installing uv..."
if ! command -v uv &>/dev/null; then
    curl -Ls https://astral.sh/uv/install.sh | bash
    export PATH="$HOME/.cargo/bin:$PATH"
else
    echo "uv is already installed"
fi

echo "Installing Python 3.12 via uv..."
uv python install 3.12

PYTHON_PATH=$(uv python find)

echo "Setting python/python3 aliases..."

if [[ "$SHELL" == *zsh ]]; then
    CONFIG_FILE="$HOME/.zshrc"
elif [[ "$SHELL" == *bash ]]; then
    CONFIG_FILE="$HOME/.bashrc"
else
    CONFIG_FILE="$HOME/.profile"
fi

# Remove any existing alias lines
sed -i.bak '/alias python=/d' "$CONFIG_FILE"
sed -i.bak '/alias python3=/d' "$CONFIG_FILE"

# Add fresh aliases
echo "alias python=\"$PYTHON_PATH\"" >> "$CONFIG_FILE"
echo "alias python3=\"$PYTHON_PATH\"" >> "$CONFIG_FILE"

echo "Installing ruff via uv..."
if ! command -v ruff &>/dev/null; then
    uv tool install ruff@latest
else
    echo "Ruff is already installed"
fi

