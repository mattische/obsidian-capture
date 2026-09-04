#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BIN_DIR="/usr/local/bin"
CONFIG_DIR="$HOME/.config/obsidian-capture"
APP_DIR="$HOME/Applications"
APP_NAME="Obsidian Capture.app"

echo "==> Checking dependencies..."

if ! command -v brew &>/dev/null; then
    echo "ERROR: Homebrew is required."
    echo "Install from: https://brew.sh"
    exit 1
fi

if ! command -v gum &>/dev/null; then
    echo "    Installing gum..."
    brew install gum
fi

echo "==> Installing obsidian-capture..."

RAW_URL="https://raw.githubusercontent.com/mattische/obsidian-capture/master/mac/obsidian-capture"

if [[ -f "$SCRIPT_DIR/obsidian-capture" ]]; then
    sudo cp "$SCRIPT_DIR/obsidian-capture" "$BIN_DIR/obsidian-capture"
else
    echo "    Downloading obsidian-capture..."
    curl -fsSL "$RAW_URL" -o /tmp/obsidian-capture
    sudo cp /tmp/obsidian-capture "$BIN_DIR/obsidian-capture"
    rm -f /tmp/obsidian-capture
fi
sudo chmod +x "$BIN_DIR/obsidian-capture"

if [[ ! -f "$CONFIG_DIR/config" ]]; then
    mkdir -p "$CONFIG_DIR"

    VAULT=$(gum input \
        --header "Path to your Obsidian vault" \
        --placeholder "~/Documents/MyVault" \
        --width 60)

    NOTE=$(gum input \
        --header "Note name (created automatically if missing)" \
        --placeholder "Inbox.md" \
        --value "Inbox.md" \
        --width 60)

    cat > "$CONFIG_DIR/config" <<EOF
# Path to your Obsidian vault
VAULT="$VAULT"

# Note where captures are saved (created automatically if it doesn't exist)
NOTE="$NOTE"
EOF
    echo "    Config written to $CONFIG_DIR/config"
else
    echo "    Config already exists — skipping."
fi

echo "==> Creating launcher app..."

mkdir -p "$APP_DIR/$APP_NAME/Contents/MacOS"
mkdir -p "$APP_DIR/$APP_NAME/Contents/Resources"

cat > "$APP_DIR/$APP_NAME/Contents/MacOS/launch" <<'LAUNCHER'
#!/usr/bin/env bash
osascript <<'APPLESCRIPT'
tell application "Terminal"
    set w to do script "obsidian-capture; exit"
    set bounds of front window to {300, 300, 900, 450}
    set custom title of front window to "Obsidian Capture"
    activate
end tell
APPLESCRIPT
LAUNCHER
chmod +x "$APP_DIR/$APP_NAME/Contents/MacOS/launch"

cat > "$APP_DIR/$APP_NAME/Contents/Info.plist" <<'PLIST'
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>CFBundleExecutable</key>
    <string>launch</string>
    <key>CFBundleIdentifier</key>
    <string>com.mattische.obsidian-capture</string>
    <key>CFBundleName</key>
    <string>Obsidian Capture</string>
    <key>CFBundlePackageType</key>
    <string>APPL</string>
    <key>CFBundleVersion</key>
    <string>1.0</string>
</dict>
</plist>
PLIST

echo ""
echo "Done!"
echo ""
echo "The app is in ~/Applications/Obsidian Capture.app"
echo ""
echo "To assign a keyboard shortcut:"
echo "  1. Open System Settings > Keyboard > Keyboard Shortcuts > App Shortcuts"
echo "  2. Click + and set Application: All Applications"
echo "  3. Menu Title: Obsidian Capture"
echo "  4. Set your shortcut (e.g. Command+Shift+I)"
echo ""
echo "Or drag 'Obsidian Capture.app' to your Dock for quick access."
