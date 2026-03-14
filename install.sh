#!/bin/bash
# =============================================================================
# ghostty-session — One-Line Installer
#
# Usage:
#   bash <(curl -sL https://raw.githubusercontent.com/Supersynergy/ghostty-session-manager/main/install.sh)
#
# Or:
#   git clone https://github.com/Supersynergy/ghostty-session-manager.git
#   cd ghostty-session-manager && bash install.sh
# =============================================================================

set -euo pipefail

G='\033[0;32m' C='\033[0;36m' Y='\033[1;33m' R='\033[0;31m' N='\033[0m'

echo ""
echo -e "${C}╔══════════════════════════════════════════════╗${N}"
echo -e "${C}║  ghostty-session — Auto Session Manager      ║${N}"
echo -e "${C}║  Ghostty + Claude Code session persistence    ║${N}"
echo -e "${C}╚══════════════════════════════════════════════╝${N}"
echo ""

BIN_DIR="$HOME/.local/bin"
DATA_DIR="${XDG_DATA_HOME:-$HOME/.local/share}/ghostty-sessions"
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

# If running via curl pipe, download files first
if [ ! -f "$SCRIPT_DIR/ghostty-session" ]; then
    echo -e "  ${C}Downloading...${N}"
    TMPDIR=$(mktemp -d)
    SCRIPT_DIR="$TMPDIR"
    curl -sL "https://raw.githubusercontent.com/Supersynergy/ghostty-session-manager/main/ghostty-session" -o "$SCRIPT_DIR/ghostty-session"
    curl -sL "https://raw.githubusercontent.com/Supersynergy/ghostty-session-manager/main/shell-hook.sh" -o "$SCRIPT_DIR/shell-hook.sh"
fi

# Create dirs
mkdir -p "$BIN_DIR" "$DATA_DIR" "$DATA_DIR/panes"

# Install binary
cp "$SCRIPT_DIR/ghostty-session" "$BIN_DIR/ghostty-session"
chmod +x "$BIN_DIR/ghostty-session"
echo -e "  ${G}✓${N} ghostty-session → $BIN_DIR/"

# Install shell hook
cp "$SCRIPT_DIR/shell-hook.sh" "$DATA_DIR/shell-hook.sh"
echo -e "  ${G}✓${N} shell-hook.sh → $DATA_DIR/"

# Add to shell RC
SHELL_RC=""
if [ "$SHELL" = "/bin/zsh" ] || [ "$SHELL" = "/usr/bin/zsh" ] || [ -n "${ZSH_VERSION:-}" ]; then
    SHELL_RC="$HOME/.zshrc"
elif [ "$SHELL" = "/bin/bash" ] || [ -n "${BASH_VERSION:-}" ]; then
    SHELL_RC="$HOME/.bashrc"
fi

SOURCE_LINE="[ -f \"$DATA_DIR/shell-hook.sh\" ] && source \"$DATA_DIR/shell-hook.sh\""

if [ -n "$SHELL_RC" ]; then
    if grep -qF "ghostty-sessions/shell-hook.sh" "$SHELL_RC" 2>/dev/null; then
        echo -e "  ${G}✓${N} Already in $SHELL_RC"
    else
        echo "" >> "$SHELL_RC"
        echo "# ghostty-session: auto save/restore tabs + Claude Code sessions" >> "$SHELL_RC"
        echo "$SOURCE_LINE" >> "$SHELL_RC"
        echo -e "  ${G}✓${N} Added to $SHELL_RC"
    fi
fi

# Check PATH
if ! echo "$PATH" | tr ':' '\n' | grep -qF "$BIN_DIR"; then
    echo ""
    echo -e "  ${Y}Add to PATH:${N} export PATH=\"\$HOME/.local/bin:\$PATH\""
fi

# Check dependencies
echo ""
echo -e "  ${C}Checking dependencies...${N}"
command -v python3 >/dev/null && echo -e "  ${G}✓${N} python3" || echo -e "  ${R}✗${N} python3 required"
command -v ghostty >/dev/null && echo -e "  ${G}✓${N} ghostty $(ghostty --version 2>/dev/null | head -1 | awk '{print $2}')" || echo -e "  ${Y}!${N} ghostty not in PATH (OK if using .app)"

echo ""
echo -e "${G}Installed!${N} Restart your shell or run: source $SHELL_RC"
echo ""
echo "  Auto features (no action needed):"
echo "    ✓ Auto-saves every 5 minutes"
echo "    ✓ Auto-saves on terminal close"
echo "    ✓ Auto-restores on Ghostty launch"
echo "    ✓ Detects & resumes Claude Code sessions"
echo ""
echo "  Manual commands:"
echo "    ghostty-session save myproject"
echo "    ghostty-session restore myproject"
echo "    ghostty-session list"
echo ""
