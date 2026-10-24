#!/usr/bin/env bash
set -euo pipefail

# =============================================================================
# Game Plane Installer
# =============================================================================
# One command to install Game Plane CLI dependencies.
#
# Usage:
#   ./install.sh [--dry-run] [--force]
#
# CLI dependencies installed locally:
#   - Argo CD CLI (manages remote clusters)
#   - kubectl (interacts with remote clusters)
#   - Ansible (verifies server connectivity)
#
# NOT installed locally (deployed to targets during bootstrap):
#   - Kind (Kubernetes in Docker)
#   - Helm
#
# On macOS, Homebrew is installed automatically if not present.
# =============================================================================

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Required CLI tools (Kind and Helm are deployed to targets during bootstrap)
REQUIRED_TOOLS="argocd kubectl ansible"

# Detect the operating system
detect_os() {
    uname -s | tr '[:upper:]' '[:lower:]'
}

# Detect the package manager
detect_package_manager() {
    local os
    os=$(detect_os)

    case "$os" in
        darwin)
            if command -v brew &>/dev/null; then
                echo "brew"
            else
                echo "brew-install"
            fi
            ;;
        linux)
            if command -v apt &>/dev/null; then
                echo "apt"
            elif command -v yay &>/dev/null; then
                echo "yay"
            elif command -v pacman &>/dev/null; then
                echo "pacman"
            elif command -v dnf &>/dev/null; then
                echo "dnf"
            elif command -v yum &>/dev/null; then
                echo "yum"
            else
                echo "none"
            fi
            ;;
        *)
            echo "none"
            ;;
    esac
}

# Check if a tool is already installed
is_installed() {
    command -v "$1" &>/dev/null
}

# Configure shell with Homebrew PATH (current + future sessions)
configure_shell() {
    local shellenv_line='eval "$(/opt/homebrew/bin/brew shellenv zsh)"'
    local zprofile="/Users/$(whoami)/.zprofile"
    local zshrc="/Users/$(whoami)/.zshrc"

    # Add to .zprofile (login shells)
    if [[ ! -f "$zprofile" ]] || ! grep -q "brew shellenv" "$zprofile"; then
        if [[ "${DRY_RUN:-false}" == "true" ]]; then
            echo -e "  ${BLUE}~${NC} Would add Homebrew shellenv to $zprofile"
        else
            touch "$zprofile"
            echo "" >> "$zprofile"
            echo "$shellenv_line" >> "$zprofile"
            echo -e "${GREEN}✓${NC} Added Homebrew shellenv to $zprofile"
        fi
    fi

    # Add to .zshrc (interactive non-login shells, e.g. VS Code terminal)
    if [[ ! -f "$zshrc" ]] || ! grep -q "brew shellenv" "$zshrc"; then
        if [[ "${DRY_RUN:-false}" == "true" ]]; then
            echo -e "  ${BLUE}~${NC} Would add Homebrew shellenv to $zshrc"
        else
            touch "$zshrc"
            echo "" >> "$zshrc"
            echo "$shellenv_line" >> "$zshrc"
            echo -e "${GREEN}✓${NC} Added Homebrew shellenv to $zshrc"
        fi
    fi

    # Apply to current session immediately (if Homebrew is present)
    if [[ -e /opt/homebrew/bin/brew ]] && ! command -v brew &>/dev/null; then
        eval "$(/opt/homebrew/bin/brew shellenv)" 2>/dev/null || true
        echo -e "${GREEN}✓${NC} Homebrew PATH applied to current session"
    fi
}

# Install Homebrew
install_brew() {
    if command -v brew &>/dev/null; then
        return 0
    fi

    echo -e "${YELLOW}→${NC} Homebrew not found. Installing Homebrew..."

    if [[ "${DRY_RUN:-false}" == "true" ]]; then
        echo -e "  ${BLUE}~${NC} /bin/bash -c \"\$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)\""
        return 0
    fi

    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

    # Configure shell with Homebrew PATH
    configure_shell

    # Add Homebrew to current session PATH
    if [[ -e /opt/homebrew/bin/brew ]]; then
        eval "$(/opt/homebrew/bin/brew shellenv)"
    fi

    echo -e "${GREEN}✓${NC} Homebrew installed successfully"
}

# Install a tool using the detected package manager
install_tool() {
    local tool="$1"
    local pm="$2"

    if is_installed "$tool"; then
        echo -e "  ${GREEN}✓${NC} $tool is already installed"
        return 0
    fi

    local install_cmd=""
    case "$pm" in
        brew|brew-install)
            install_cmd="brew install $tool"
            ;;
        apt)
            install_cmd="sudo apt update && sudo apt install -y $tool"
            ;;
        yay)
            install_cmd="yay -S $tool"
            ;;
        pacman)
            install_cmd="sudo pacman -S $tool"
            ;;
        dnf)
            install_cmd="sudo dnf install -y $tool"
            ;;
        yum)
            install_cmd="sudo yum install -y $tool"
            ;;
        *)
            echo -e "  ${YELLOW}⚠${NC} $tool: no supported package manager, please install manually"
            return 1
            ;;
    esac

    if [[ "${DRY_RUN:-false}" == "true" ]]; then
        echo -e "  ${BLUE}~${NC} $tool: $install_cmd (dry-run)"
        return 0
    fi

    echo -e "  ${YELLOW}→${NC} Installing $tool..."
    if eval "$install_cmd"; then
        echo -e "  ${GREEN}✓${NC} $tool installed successfully"
    else
        echo -e "  ${RED}✗${NC} Failed to install $tool"
        return 1
    fi
}

# Print usage information
print_usage() {
    echo "Usage: $0 [--dry-run] [--force]"
    echo ""
    echo "Options:"
    echo "  --dry-run   Show what would be installed without making changes"
    echo "  --force     Force reinstall already installed tools"
    echo "  -h, --help  Show this help message"
}

# Main installation logic
main() {
    local dry_run="false"
    local force="false"

    # Parse arguments
    while [[ $# -gt 0 ]]; do
        case "$1" in
            --dry-run)
                dry_run="true"
                export DRY_RUN="true"
                shift
                ;;
            --force)
                force="true"
                shift
                ;;
            -h|--help)
                print_usage
                exit 0
                ;;
            *)
                echo -e "${RED}Error: Unknown option $1${NC}"
                print_usage
                exit 1
                ;;
        esac
    done

    echo -e "${BLUE}╔══════════════════════════════════════╗${NC}"
    echo -e "${BLUE}║     Game Plane Installer             ║${NC}"
    echo -e "${BLUE}╚══════════════════════════════════════╝${NC}"
    echo ""

    # Detect OS and package manager
    local os pm
    os=$(detect_os)
    pm=$(detect_package_manager)

    echo -e "${GREEN}✓${NC} OS: $os"
    echo -e "${GREEN}✓${NC} Package manager: $pm"
    echo ""

    # On macOS, install Homebrew if not present
    if [[ "$os" == "darwin" && "$pm" == "brew-install" ]]; then
        install_brew
        # Re-detect after installing Homebrew (only if brew actually exists)
        if command -v brew &>/dev/null; then
            eval "$(/opt/homebrew/bin/brew shellenv)" 2>/dev/null || true
            pm="brew"
        fi
    fi

    if [[ "$pm" == "none" ]]; then
        echo -e "${RED}Error: No supported package manager detected.${NC}"
        echo "Please install one of: brew, apt, yay, pacman, dnf, yum"
        exit 1
    fi

    # Install each tool
    local failed=0
    for tool in $REQUIRED_TOOLS; do
        if [[ "$force" == "true" ]]; then
            echo -e "  ${YELLOW}→${NC} Force reinstalling $tool..."
            install_tool "$tool" "$pm" || ((failed++)) || true
        else
            install_tool "$tool" "$pm" || ((failed++)) || true
        fi
    done

    echo ""
    if [[ "$dry_run" == "true" ]]; then
        echo -e "${BLUE}Dry-run complete. No changes were made.${NC}"
    elif [[ "$failed" -eq 0 ]]; then
        echo -e "${GREEN}✓ Game Plane installed successfully!${NC}"
        echo ""
        echo "Next steps:"
        echo "  gameplane bootstrap --repo <your-repo>"
        echo "  gameplane status"
    else
        echo -e "${RED}✗ $failed tool(s) failed to install.${NC}"
        echo "Please install them manually and re-run this script."
        exit 1
    fi
}

main "$@"
