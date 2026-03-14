#!/bin/bash
# =============================================================================
# ghostty-session — Shell Hook (source in ~/.zshrc or ~/.bashrc)
#
# Auto-features:
#   ✓ Every prompt:  registers CWD + Claude Code detection
#   ✓ Every 5 min:   auto-saves entire session
#   ✓ Terminal close: saves before exit
#   ✓ Ghostty start: restores last session
# =============================================================================

# Only run inside Ghostty
[ "$TERM_PROGRAM" != "ghostty" ] && [ -z "$GHOSTTY_RESOURCES_DIR" ] && return 0 2>/dev/null

# Find binary
_GS_BIN=""
for _c in "$HOME/.local/bin/ghostty-session" "/usr/local/bin/ghostty-session"; do
    [ -x "$_c" ] && _GS_BIN="$_c" && break
done
[ -z "$_GS_BIN" ] && return 0 2>/dev/null

# --- Auto-save on exit ---
trap '"$_GS_BIN" autosave 2>/dev/null' HUP EXIT

# --- Prompt hook: register pane + periodic save ---
_GS_LAST_SAVE=${_GS_LAST_SAVE:-0}

_gs_prompt() {
    # Register this pane (background, non-blocking)
    "$_GS_BIN" register-pane $$ "$PWD" 2>/dev/null &

    # Auto-save every 300s (5 min)
    local _now; _now=$(date +%s)
    if (( _now - _GS_LAST_SAVE >= 300 )); then
        _GS_LAST_SAVE=$_now
        "$_GS_BIN" autosave 2>/dev/null &
    fi

    # OSC 7: report CWD to Ghostty
    printf '\e]7;file://%s%s\e\\' "${HOSTNAME:-localhost}" "$PWD"
}

# Hook into shell
if [ -n "$ZSH_VERSION" ]; then
    autoload -U add-zsh-hook 2>/dev/null
    add-zsh-hook precmd _gs_prompt
elif [ -n "$BASH_VERSION" ]; then
    PROMPT_COMMAND="${PROMPT_COMMAND:+$PROMPT_COMMAND;}_gs_prompt"
fi

# --- Auto-restore on first Ghostty launch ---
if [ -z "$_GS_RESTORED" ]; then
    export _GS_RESTORED=1 _GS_LAST_SAVE=$(date +%s)

    if [ -f "${XDG_DATA_HOME:-$HOME/.local/share}/ghostty-sessions/.autosave.json" ]; then
        # Only in the first shell (not in tabs opened by restore)
        if [ "$(pgrep -x ghostty 2>/dev/null | wc -l | tr -d ' ')" -le 1 ]; then
            echo -e "\033[2m[ghostty-session] Restoring last session...\033[0m"
            "$_GS_BIN" auto-restore
        fi
    fi
fi

# Aliases
alias gs='ghostty-session'
alias gss='ghostty-session save'
alias gsr='ghostty-session restore'
alias gsl='ghostty-session list'
