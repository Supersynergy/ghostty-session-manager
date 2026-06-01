# ghostty-session — Auto Session Manager for Ghostty + Claude Code

> **Never lose your terminal tabs or Claude Code conversations again.**
> Auto-saves everything. Auto-restores on restart. Zero config needed.

[![License: MIT](https://img.shields.io/badge/License-MIT-green.svg)](LICENSE)

## The Problem

Ghostty has great tabs and splits, but **restarting it kills everything**:
- All your tabs and working directories — gone
- All running Claude Code sessions — gone
- Your entire workspace layout — gone

## The Solution

`ghostty-session` runs silently in the background:

```
Every prompt    → tracks your tabs + detects Claude Code sessions
Every 5 min     → auto-saves everything
Terminal close  → saves before exit
Ghostty launch  → restores tabs + resumes Claude Code automatically
```

## Install (One Line)

```bash
bash <(curl -sL https://raw.githubusercontent.com/Supersynergy/ghostty-session-manager/main/install.sh)
```

Or clone:
```bash
git clone https://github.com/Supersynergy/ghostty-session-manager.git
cd ghostty-session-manager && bash install.sh
```

**That's it.** Restart your shell. Everything is automatic from now on.

## How It Works

### 1. Tracking (automatic, every prompt)

The shell hook runs on every prompt and records:
- Current working directory (via OSC 7)
- Whether Claude Code is running as a child process
- The Claude Code session UUID (mapped from your project path)

### 2. Claude Code Session Matching

```
Your CWD: /Users/you/myproject
    ↓
Claude path hash: -Users-you-myproject
    ↓
~/.claude/projects/-Users-you-myproject/*.jsonl
    ↓
Latest session UUID: a1b2c3d4-e5f6-...
    ↓
Restore command: claude --resume a1b2c3d4-e5f6-...
```

This means your **exact conversation** is restored — not just a new Claude session.

### 3. Save Format

```json
{
  "name": "default",
  "version": "2.1.0",
  "saved_at": "2026-03-14T15:00:00Z",
  "panes": [
    {"pid": 12345, "cwd": "/Users/you/project-a", "claude_session": "a1b2c3d4-...", "claude_running": true},
    {"pid": 12346, "cwd": "/Users/you/project-b", "claude_session": "", "claude_running": false}
  ],
  "restore_plan": [
    {"cwd": "/Users/you/project-a", "claude_session": "a1b2c3d4-...", "claude_running": true},
    {"cwd": "/Users/you/project-b", "claude_session": "", "claude_running": false}
  ]
}
```

### 4. Restore (automatic on Ghostty launch)

```
Tab 1: cd /Users/you/project-a && claude --resume a1b2c3d4-...
Tab 2: cd /Users/you/project-b
```

On macOS, tabs are opened via AppleScript. On Linux, directories are restored in the current terminal.

## Manual Commands

```bash
ghostty-session save myproject     # Named save
ghostty-session restore myproject  # Named restore
ghostty-session list               # Show all sessions + Claude info
ghostty-session delete myproject   # Delete a session
```

### Aliases (after install)

```bash
gss myproject   # save
gsr myproject   # restore
gsl             # list
gs              # ghostty-session
```

## What Gets Restored

| Feature | Auto-Save | Auto-Restore |
|---------|-----------|-------------|
| Tab working directories | ✓ every prompt | ✓ on launch |
| Claude Code sessions | ✓ by UUID mapping | ✓ via `--resume` |
| Tab count and order | ✓ | ✓ (macOS via AppleScript) |
| Recent Claude sessions | ✓ last 24h from meta | shown in `list` |
| Named sessions | ✓ manual `save` | ✓ manual `restore` |

## What Is NOT Restored

- Running processes (use tmux for that)
- Split layouts (tabs only, splits planned for v3)
- Scrollback buffer (Claude Code has its own history)
- Environment variables (except CWD)

## Requirements

- **Ghostty** 1.1.0+ (any version)
- **Python 3** (for JSON parsing)
- **macOS** for full tab automation (Linux: CWD restore only)
- **Claude Code** (optional — works without it too)

## Configuration

None needed. But you can customize auto-save interval:

```bash
# In your .zshrc, BEFORE sourcing the hook:
export GHOSTTY_AUTOSAVE_INTERVAL=600  # seconds (default: 300)
```

## Uninstall

```bash
rm ~/.local/bin/ghostty-session
rm -rf ~/.local/share/ghostty-sessions
# Remove the source line from ~/.zshrc
```

## How This Compares

| | ghostty-session | tmux | Zellij |
|---|---|---|---|
| **Session save/restore** | ✓ automatic | ✓ manual (plugins) | ✓ manual |
| **Claude Code integration** | ✓ auto-resume | ✗ | ✗ |
| **Native Ghostty tabs** | ✓ | ✗ (own tabs) | ✗ (own tabs) |
| **GPU rendering preserved** | ✓ | ✓ | ✓ |
| **Zero config** | ✓ | ✗ | ✗ |
| **Process persistence** | ✗ | ✓ | ✓ |

**Use ghostty-session if** you want automatic tab + Claude Code persistence with native Ghostty.
**Use tmux/Zellij if** you need running process persistence (long-running servers, builds).
**Use both** for maximum resilience.

## License

MIT

---

**Built by [@Supersynergy](https://github.com/Supersynergy)** | Works with [awesome-agentic-coding](https://github.com/Supersynergy/awesome-agentic-coding)
