#!/usr/bin/env bash

# CCMS Installation Script

set -euo pipefail

# Colors
GREEN='\033[0;32m'
RED='\033[0;31m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m'

# Default installation directory
DEFAULT_INSTALL_DIR="$HOME/.local/bin"

print_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[✓]${NC} $1"
}

print_error() {
    echo -e "${RED}[✗]${NC} $1" >&2
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

# Detect OS
detect_os() {
    if [[ "$OSTYPE" == "linux-gnu"* ]]; then
        if [ -f /etc/os-release ]; then
            . /etc/os-release
            OS=$ID
            OS_FAMILY=$ID_LIKE
        else
            OS="linux"
            OS_FAMILY=""
        fi
    elif [[ "$OSTYPE" == "darwin"* ]]; then
        OS="macos"
        OS_FAMILY="macos"
    elif [[ "$OSTYPE" == "freebsd"* ]]; then
        OS="freebsd"
        OS_FAMILY="bsd"
    else
        OS="unknown"
        OS_FAMILY=""
    fi
}

# Check if rsync is installed
check_rsync() {
    if command -v rsync &> /dev/null; then
        RSYNC_VERSION=$(rsync --version | head -n1)
        print_success "rsync is installed: $RSYNC_VERSION"
        return 0
    else
        print_error "rsync is not installed"
        return 1
    fi
}

# Show rsync installation instructions
show_rsync_install() {
    echo
    print_warning "rsync is required for CCMS to work"
    echo
    echo "Installation instructions for your system:"
    echo
    
    case "$OS" in
        "ubuntu"|"debian")
            echo "  sudo apt update"
            echo "  sudo apt install rsync"
            ;;
        "fedora"|"rhel"|"centos")
            echo "  sudo dnf install rsync"
            ;;
        "arch"|"manjaro")
            echo "  sudo pacman -S rsync"
            ;;
        "opensuse")
            echo "  sudo zypper install rsync"
            ;;
        "alpine")
            echo "  sudo apk add rsync"
            ;;
        "macos")
            echo "  # rsync should be pre-installed on macOS"
            echo "  # If not, install via Homebrew:"
            echo "  brew install rsync"
            ;;
        "freebsd")
            echo "  sudo pkg install rsync"
            ;;
        *)
            if [[ "$OS_FAMILY" == *"debian"* ]]; then
                echo "  sudo apt update"
                echo "  sudo apt install rsync"
            elif [[ "$OS_FAMILY" == *"rhel"* ]] || [[ "$OS_FAMILY" == *"fedora"* ]]; then
                echo "  sudo dnf install rsync"
                echo "  # or"
                echo "  sudo yum install rsync"
            else
                echo "  Please install rsync using your system's package manager"
                echo "  Common commands:"
                echo "  - Debian/Ubuntu: sudo apt install rsync"
                echo "  - Fedora/RHEL: sudo dnf install rsync"
                echo "  - Arch: sudo pacman -S rsync"
                echo "  - macOS: brew install rsync"
                echo "  - FreeBSD: sudo pkg install rsync"
            fi
            ;;
    esac
    
    echo
    read -p "Would you like to continue anyway? [y/N] " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        print_info "Installation cancelled. Please install rsync and run this script again."
        exit 1
    fi
}

# Main installation process
main() {
    print_info "CCMS Installation Script"
    echo
    
    # Detect OS
    detect_os
    print_info "Detected OS: $OS"
    
    # Check for rsync
    if ! check_rsync; then
        show_rsync_install
    fi
    
    # Check if running from ccms directory
    if [[ ! -f "ccms" ]]; then
        print_error "Installation script must be run from the ccms directory"
        print_info "Please cd into the ccms directory and run: ./install.sh"
        exit 1
    fi
    
    # Get installation directory
    echo
    read -p "Installation directory [$DEFAULT_INSTALL_DIR]: " INSTALL_DIR
    INSTALL_DIR="${INSTALL_DIR:-$DEFAULT_INSTALL_DIR}"

    # Create installation directory if needed
    if [[ ! -d "$INSTALL_DIR" ]]; then
        print_info "Creating directory: $INSTALL_DIR"
        mkdir -p "$INSTALL_DIR" || {
            print_error "Failed to create installation directory"
            exit 1
        }
    fi

    # Check if ccms already exists
    if [[ -f "$INSTALL_DIR/ccms" ]]; then
        read -p "ccms already exists in $INSTALL_DIR. Overwrite? [y/N] " -n 1 -r
        echo
        if [[ ! $REPLY =~ ^[Yy]$ ]]; then
            print_info "Installation cancelled"
            exit 0
        fi
    fi

    # Copy ccms script
    print_info "Installing ccms to $INSTALL_DIR"
    cp ccms "$INSTALL_DIR/" || {
        print_error "Failed to copy ccms script"
        exit 1
    }

    # Make executable
    chmod +x "$INSTALL_DIR/ccms" || {
        print_error "Failed to make ccms executable"
        exit 1
    }

    print_success "ccms installed successfully!"

    # Check if directory is in PATH
    if [[ ":$PATH:" != *":$INSTALL_DIR:"* ]]; then
        print_info "Note: $INSTALL_DIR is not in your PATH"
        echo
        echo "Add it to your PATH by adding this line to your shell config:"
        echo
        if [[ "$SHELL" == *"zsh"* ]]; then
            echo "  echo 'export PATH=\"\$PATH:$INSTALL_DIR\"' >> ~/.zshrc"
            echo "  source ~/.zshrc"
        elif [[ "$SHELL" == *"bash"* ]]; then
            echo "  echo 'export PATH=\"\$PATH:$INSTALL_DIR\"' >> ~/.bashrc"
            echo "  source ~/.bashrc"
        else
            echo "  export PATH=\"\$PATH:$INSTALL_DIR\""
        fi
        echo
    fi

    # Test installation
    if command -v ccms &> /dev/null; then
        print_success "ccms is available in your PATH"
        echo
        echo "Next steps:"
        echo "1. Run 'ccms config' to set up your remote server"
        echo "2. Run 'ccms push' to sync your claude directory"
        echo "3. Run 'ccms help' for more information"
    else
        echo "Run 'ccms config' to get started (after updating your PATH if needed)"
    fi
}

# Run main function
main