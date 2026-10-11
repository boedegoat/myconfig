# tmux Setup Guide

A complete guide to setting up tmux with TPM, Catppuccin theme, and custom keybindings.

---

## Prerequisites

Make sure `tmux` is installed on your system.

```bash
# Debian/Ubuntu
sudo apt install tmux

# Arch
sudo apt install tmux

# macOS
brew install tmux
```

Verify:
```bash
tmux -V
```

---

## 1. Install TPM (Tmux Plugin Manager)

```bash
git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm
```

---

## 2. Write the Config File

Create `~/.tmux.conf`:

```bash
vim ~/.tmux.conf
```

Paste contents from [here](.tmux.conf)

---

## 3. Launch tmux & Install Plugins

Start a new tmux session:

```bash
tmux
```

Install all plugins via TPM:

```
Ctrl+s  then  Shift+i
```

TPM will clone Catppuccin and all other listed plugins into `~/.config/tmux/plugins/`.

---

## 4. Reload the Config

After TPM finishes:

```
Ctrl+s  then  r
```

---

## Keybindings Reference

| Key | Action |
|-----|--------|
| `Ctrl+s` | Prefix key |
| `Prefix + r` | Reload tmux config |
| `Prefix + h` | Select pane left |
| `Prefix + j` | Select pane down |
| `Prefix + k` | Select pane up |
| `Prefix + l` | Select pane right |
| `Prefix + Shift+i` | Install plugins (TPM) |
| `Prefix + Shift+u` | Update plugins (TPM) |
| `Prefix + Alt+u` | Remove unused plugins (TPM) |

---

## Troubleshooting

### Catppuccin not loading / status bar blank

Check that the plugin path is correct:
```bash
ls ~/.config/tmux/plugins/catppuccin/tmux/catppuccin.tmux
```
If missing, re-run TPM install with `Prefix + Shift+i`.

### Battery module not showing

Confirm `acpi` is installed and returns output:
```bash
acpi
# example output: Battery 0: Discharging, 87%
```

### Colors look wrong

Make sure your terminal emulator is set to **256 color** or **true color** mode.
For most terminals, add this to your shell profile:
```bash
export TERM=xterm-256color
```

### Plugin path mismatch

If you skip the `set-environment` line, TPM installs to `~/.tmux/plugins/` by default.
In that case, change the catppuccin load line to:
```tmux
run '~/.tmux/plugins/catppuccin/tmux/catppuccin.tmux'
```

---

## Directory Structure (after setup)

```
~/.tmux.conf
~/.tmux/
└── plugins/
    └── tpm/               ← TPM itself
~/.config/tmux/
└── plugins/
    ├── catppuccin/
    │   └── tmux/
    │       └── catppuccin.tmux
    └── (other plugins...)
```
