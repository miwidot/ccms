#!/bin/bash

# CCMS Installation Script

set -euo pipefail

# Colors
GREEN='\033[0;32m'
RED='\033[0;31m'
BLUE='\033[0;34m'
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

# Check if running from ccms directory
if [[ ! -f "ccms" ]]; then
    print_error "Installation script must be run from the ccms directory"
    print_info "Please cd into the ccms directory and run: ./install.sh"
    exit 1
fi

# Get installation directory
print_info "CCMS Installation Script"
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