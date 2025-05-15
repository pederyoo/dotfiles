set -e

PLATFORM=""
DISTRO=""
USE_WSL_BACKEND=false

unameOut="$(uname -s)"

case "${unameOut}" in
    Darwin*)
        PLATFORM="macos"
        ;;
    CYGWIN*|MINGW*|MSYS*)
        PLATFORM="windows"
        ;;
    Linux*)
        if grep -qEi "microsoft|wsl" /proc/version &>/dev/null; then
            PLATFORM="wsl"
            USE_WSL_BACKEND=true

            # Check distro
            if [ -f /etc/os-release ]; then
                . /etc/os-release
                DISTRO="$ID"
                if [ "$DISTRO" != "ubuntu" ]; then
                    echo "This script only supports Ubuntu in WSL. Found: $DISTRO"
                    exit 1
                fi
            else
                echo "Cannot determine distro inside WSL."
                exit 1
            fi
        else
            echo "Only WSL (with Ubuntu) is supported"
            exit 1
        fi
        ;;
    *)
        echo "Unsupported OS: $unameOut"
        exit 1
        ;;
esac

echo "Platform detected: $PLATFORM"
[ -n "$DISTRO" ] && echo "Distro detected: $DISTRO"

# Run appropriate setup
case "$PLATFORM" in
    macos)
        echo "Running macOS setup..."
        source ./brew.sh
        source ./python-environment.sh
        ;;
    wsl)
        echo "Running WSL (Ubuntu) setup..."
        source ./apt.sh
        source ./python-environment.sh
        source ./manual.sh
        ;;
    windows)
        echo "Windows setup is not yet implemented."
        ;;
esac


