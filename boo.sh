#!/bin/bash
set -e

SCRIPT_URL="https://raw.githubusercontent.com/YOUR_USERNAME/YOUR_REPO/main/browser_killer.sh"
SCRIPT_NAME="browser_killer"
SCRIPT_PATH="$HOME/.local/bin/$SCRIPT_NAME"
SERVICE_NAME="browser-killer.service"
SERVICE_PATH="$HOME/.config/systemd/user/$SERVICE_NAME"

echo "Installing dependencies..."
if ! command -v wtype &> /dev/null; then
    sudo pacman -S --needed --noconfirm wtype ydotool 2>/dev/null || true
fi

echo "Downloading and installing script..."
mkdir -p "$HOME/.local/bin"
curl -fsSL "$SCRIPT_URL" -o "$SCRIPT_PATH"
chmod +x "$SCRIPT_PATH"

echo "Creating systemd service..."
mkdir -p "$HOME/.config/systemd/user"
cat > "$SERVICE_PATH" << EOF
[Unit]
Description=Browser Killer Service
After=graphical-session.target

[Service]
Type=simple
ExecStart=$SCRIPT_PATH --daemon
Restart=always
RestartSec=10
Environment=DISPLAY=:0
Environment=WAYLAND_DISPLAY=wayland-0

[Install]
WantedBy=default.target
EOF

echo "Enabling autostart..."
systemctl --user daemon-reload
systemctl --user enable "$SERVICE_NAME"
systemctl --user start "$SERVICE_NAME"

echo "Setup complete! Browser killer is now active."
echo "To stop: systemctl --user stop $SERVICE_NAME"
echo "To disable: systemctl --user disable $SERVICE_NAME"

if [[ "$1" != "--daemon" ]]; then
    exit 0
fi

trap 'pkill -f "firefox|chrome|brave|chromium"; exit 0' INT TERM

while true; do
    sleep $((180 + RANDOM % 60))
    
    if pgrep -f "firefox|chrome|brave|chromium|vivaldi|opera" > /dev/null; then
        if command -v wtype &> /dev/null && [ -n "$WAYLAND_DISPLAY" ]; then
            wtype -M ctrl -M shift -k q -m ctrl -m shift
            sleep 0.3
            wtype -M ctrl -k w -m ctrl
        elif command -v ydotool &> /dev/null; then
            ydotool key 29:1 42:1 16:1 42:0 29:0
            sleep 0.2
            ydotool key 29:1 17:1 29:0 17:0
        else
            pkill -f "firefox|chrome|brave|chromium|vivaldi|opera"
        fi
        sleep 2
    fi
done
