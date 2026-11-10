# myconfig

Personal tmux configuration and helper scripts: a minimal monochrome status bar,
`Ctrl+s` prefix, vi-style copy mode, and a "zen mode" that centers the active
pane at a fixed width.

## Contents

| Path | Purpose |
|------|---------|
| `.tmux.conf` | tmux configuration |
| `tmux/scripts/tmux-zen.sh` | Zen-mode and split helpers used by `.tmux.conf` |
| `setup-kali.sh` | Optional bootstrap script for Kali/Debian machines |

## Requirements

- **tmux 3.x** (tested with tmux 3.6)
- **git**
- Linux or macOS

Install the prerequisites:

```bash
# Ubuntu / Debian / Kali
sudo apt update
sudo apt install -y tmux git

# macOS
brew install tmux git
```

Verify:

```bash
tmux -V
```

---

## Installation

These steps are what I use on this Ubuntu 26.04 machine (tmux 3.6); they also
work on Debian/Kali and macOS.

> **Important:** the keybindings in `.tmux.conf` call the script by its path,
> `~/myconfig/tmux/scripts/tmux-zen.sh`. Clone the repo to `~/myconfig`
> exactly, otherwise `Prefix + z`, `Prefix + %`, and `Prefix + "` will fail.

### 1. Clone the repo and TPM

```bash
git clone https://github.com/boedegoat/myconfig.git ~/myconfig
git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm
```

### 2. Install the tmux config

Copy it:

```bash
cp ~/myconfig/.tmux.conf ~/.tmux.conf
```

Or keep it in sync with the repo using a symlink:

```bash
ln -sf ~/myconfig/.tmux.conf ~/.tmux.conf
```

### 3. Make the helper scripts executable

```bash
chmod +x ~/myconfig/tmux/scripts/tmux-zen.sh
```

Git normally preserves the executable bit, but this makes the install
idempotent.

### 4. Start tmux and install the TPM plugins

```bash
tmux new-session -A -s main
```

Inside tmux, press:

```
Ctrl+s  then  Shift+i
```

Wait for TPM to finish installing the plugins.

### 5. Reload the config

Inside tmux:

```
Ctrl+s  then  r
```

Or from a shell:

```bash
tmux source-file ~/.tmux.conf
```

### Quick install (copy and paste)

```bash
git clone https://github.com/boedegoat/myconfig.git ~/myconfig && \
git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm && \
cp ~/myconfig/.tmux.conf ~/.tmux.conf && \
chmod +x ~/myconfig/tmux/scripts/tmux-zen.sh
```

Then start tmux if it is not already running, reload the config
(`Ctrl+s` then `r`), and install the plugins (`Ctrl+s` then `Shift+i`).

### Updating an existing install

```bash
cd ~/myconfig
git pull
chmod +x tmux/scripts/tmux-zen.sh

# If ~/.tmux.conf is a copy (not a symlink), refresh it:
cp ~/myconfig/.tmux.conf ~/.tmux.conf

tmux source-file ~/.tmux.conf   # with tmux running
```

---

## tmux/scripts

### `tmux-zen.sh`

Centers the active pane at a fixed width by creating two temporary padding
panes on either side. Zen state is stored in the window option
`@zen_center_pane`; the padding panes are marked with `@zen_padding=1` so they
can be removed cleanly.

The script requires:

- tmux 3.x
- a single pane in the window when enabling zen mode
- a window at least `width + 12` columns wide (for example, 132 columns for the
  default 120-column zen width)

#### Usage

```bash
~/myconfig/tmux/scripts/tmux-zen.sh toggle [width]  # default width: 120
~/myconfig/tmux/scripts/tmux-zen.sh on [width]
~/myconfig/tmux/scripts/tmux-zen.sh off
~/myconfig/tmux/scripts/tmux-zen.sh split-horizontal
~/myconfig/tmux/scripts/tmux-zen.sh split-vertical
```

| Action | Description |
|--------|-------------|
| `toggle [width]` | Enable zen mode if off, disable it if on |
| `on [width]` | Center the current pane at `width` columns |
| `off` | Remove the padding panes and restore the full-width layout |
| `split-horizontal` | Leave zen mode, then split the pane left/right |
| `split-vertical` | Leave zen mode, then split the pane top/bottom |

`split-horizontal` and `split-vertical` keep the current working directory of
the pane they split.

#### Keybindings

These are wired up in `.tmux.conf`:

| Key | Action |
|-----|--------|
| `Prefix + z` | Toggle zen mode at 120 columns |
| `Prefix + %` | Leave zen mode and split horizontally |
| `Prefix + "` | Leave zen mode and split vertically |

#### Verify the script

```bash
test -x ~/myconfig/tmux/scripts/tmux-zen.sh && echo "script OK"
```

Then, inside tmux:

```bash
tmux run-shell '~/myconfig/tmux/scripts/tmux-zen.sh toggle 120'
```

Run the same command again (or press `Prefix + z`) to turn zen mode off.

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
| `Prefix + c` | New window in the current directory |
| `Prefix + b` | Open the `btw` session in a 90% x 90% popup |
| `Prefix + z` | Toggle zen mode (120 columns) |
| `Prefix + %` | Leave zen mode and split horizontally |
| `Prefix + "` | Leave zen mode and split vertically |
| `Prefix + Shift+i` | Install plugins (TPM) |
| `Prefix + Shift+u` | Update plugins (TPM) |
| `Prefix + Alt+u` | Remove unused plugins (TPM) |

Other behavior:

- Mouse support is enabled, including wheel scrolling and drag selection.
- Copy mode uses vi keys: `v` starts a selection, `V` selects a line,
  `Ctrl+v` toggles rectangle selection, `y` yanks and exits copy mode, and
  `Y` yanks while staying in copy mode.
- The status bar uses Nerd Font glyphs, so install a Nerd Font in your terminal
  for the icons to render correctly.

---

## Troubleshooting

### `tmux-zen.sh: not found` or `No such file or directory`

The repo is not at `~/myconfig`. Check:

```bash
ls -l ~/myconfig/tmux/scripts/tmux-zen.sh
```

Either clone the repo there or update the three `run-shell` paths in
`~/.tmux.conf`:

```tmux
bind-key z run-shell '~/myconfig/tmux/scripts/tmux-zen.sh toggle 120'
bind-key % run-shell '~/myconfig/tmux/scripts/tmux-zen.sh split-horizontal'
bind-key '"' run-shell '~/myconfig/tmux/scripts/tmux-zen.sh split-vertical'
```

### `Permission denied`

```bash
chmod +x ~/myconfig/tmux/scripts/tmux-zen.sh
```

### `Zen mode only works with a single pane`

Zen mode can only be enabled from a single-pane window. Close the extra panes
first, or turn zen mode off with `Prefix + z` before splitting.

### `Zen mode: window is too narrow`

The terminal must be at least `width + 12` columns wide. Resize the terminal or
use a smaller width:

```bash
~/myconfig/tmux/scripts/tmux-zen.sh toggle 100
```

### TPM plugin install does not start

Confirm TPM exists and is loaded by the config:

```bash
ls ~/.tmux/plugins/tpm/tpm
grep "plugins/tpm/tpm" ~/.tmux.conf
```

Reload the config (`Prefix + r`), then press `Ctrl+s` then `Shift+i` again.

### Copy to clipboard does not work on Linux

`.tmux.conf` uses `pbcopy`, which is macOS-only. On Ubuntu/Debian, install
`xclip` and replace `pbcopy` in the `y`/`Y` bindings with:

```bash
xclip -selection clipboard -i
```

On Wayland, use `wl-copy` from the `wl-clipboard` package instead.

### Status bar icons show up as boxes

Install a Nerd Font and select it in your terminal emulator. The status bar and
window list use Nerd Font glyphs.

---

## Directory Structure (after setup)

```
~/myconfig/
├── .tmux.conf
├── README.md
├── setup-kali.sh
└── tmux/
    └── scripts/
        └── tmux-zen.sh

~/.tmux.conf                 ← copy or symlink of ~/myconfig/.tmux.conf
~/.tmux/
└── plugins/
    └── tpm/                 ← Tmux Plugin Manager
```
