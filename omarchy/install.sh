#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BIN_DIR="$HOME/.local/bin"
CONFIG_DIR="$HOME/.config/obsidian-capture"
HYPR_BINDINGS="$HOME/.config/hypr/bindings.lua"
HYPR_MAIN="$HOME/.config/hypr/hyprland.lua"

echo "==> Checking dependencies..."

if ! command -v gum &>/dev/null; then
    echo "ERROR: 'gum' is required but not installed."
    echo "Install with: pacman -S gum  or  brew install gum"
    exit 1
fi

if ! command -v foot &>/dev/null; then
    echo "ERROR: 'foot' terminal is required but not installed."
    exit 1
fi

if ! command -v hyprctl &>/dev/null; then
    echo "WARNING: hyprctl not found — skipping Hyprland integration."
    SKIP_HYPR=true
else
    SKIP_HYPR=false
fi

echo "==> Installing obsidian-capture..."

mkdir -p "$BIN_DIR"
cp "$SCRIPT_DIR/bin/obsidian-capture" "$BIN_DIR/obsidian-capture"
chmod +x "$BIN_DIR/obsidian-capture"

if [[ ! -f "$CONFIG_DIR/config" ]]; then
    mkdir -p "$CONFIG_DIR"

    VAULT=$(gum input \
        --header "Path to your Obsidian vault" \
        --placeholder "~/Dropbox/MyVault" \
        --width 60)

    NOTE=$(gum input \
        --header "Note name (created automatically if missing)" \
        --placeholder "Inbox.md" \
        --value "Inbox.md" \
        --width 60)

    cat > "$CONFIG_DIR/config" <<EOF
# Path to your Obsidian vault
VAULT=$VAULT

# Note where captures are saved (created automatically if it doesn't exist)
NOTE=$NOTE
EOF
    echo "    Config written to $CONFIG_DIR/config"
else
    echo "    Config already exists at $CONFIG_DIR/config — skipping."
fi

if [[ "$SKIP_HYPR" == false ]]; then
    MARKER="obsidian-capture"

    if [[ -f "$HYPR_BINDINGS" ]] && ! grep -q "$MARKER" "$HYPR_BINDINGS"; then
        cat >> "$HYPR_BINDINGS" <<'EOF'

-- obsidian-capture
o.bind("SUPER + I", "Obsidian Capture", "uwsm-app -- foot --app-id=obsidian-capture -e obsidian-capture")
o.bind("SUPER + SHIFT + I", "Obsidian Capture config", "uwsm-app -- foot --app-id=obsidian-capture -e obsidian-capture --config")
EOF
        echo "    Keybindings added to $HYPR_BINDINGS"
    else
        echo "    Keybindings already present — skipping."
    fi

    if [[ -f "$HYPR_MAIN" ]] && ! grep -q "$MARKER" "$HYPR_MAIN"; then
        cat >> "$HYPR_MAIN" <<'EOF'

-- obsidian-capture
o.window("obsidian-capture", { float = true, pin = true, size = "560 240", center = true })
EOF
        echo "    Window rules added to $HYPR_MAIN"
    else
        echo "    Window rules already present — skipping."
    fi

    hyprctl reload
    echo "    Hyprland reloaded."
fi

echo ""
echo "Done! Use Super+I to capture, Super+Shift+I to edit config."
