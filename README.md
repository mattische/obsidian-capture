# obsidian-capture

A minimal capture tool for Obsidian on Hyprland. Press a keybinding, type text or paste a URL, optionally add tags — it lands as a checkbox at the top of a note.

## Features

- Floating TUI window triggered by a keybinding
- Saves entries as Obsidian checkboxes with timestamp
- Optional tags (e.g. `sr, annan` → `#sr #annan`)
- Editable config from within the app

## Requirements

- [Hyprland](https://hyprland.org/) with [Omarchy](https://omarchy.org/)
- [foot](https://codeberg.org/dnkl/foot) terminal
- [gum](https://github.com/charmbracelet/gum)

## Install

```bash
git clone https://github.com/yourname/obsidian-capture
cd obsidian-capture
bash install.sh
```

The installer will ask for your vault path and note name, then wire up Hyprland keybindings automatically.

## Usage

| Keybinding | Action |
|---|---|
| `Super+I` | Open capture (text + optional tags) |
| `Super+Shift+I` | Edit config (vault path, note name) |

Entries are saved to the top of your note as:

```
- [ ] 2026-09-03 14:22 https://example.com #sr #annan
```

## Config

`~/.config/obsidian-capture/config`:

```bash
VAULT=~/Dropbox/MyVault
NOTE=Inbox.md
```

`NOTE` can include subdirectories: `NOTE=TODOs/Inbox.md`
