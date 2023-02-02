#!/bin/bash
# global variables
NOW=`date +"%Y%m%d_%H%M%S"`
SCRIPT_DIR="$(realpath "$(dirname "$0")")"
CARDANOBI_DIR="$(realpath "$(dirname "$SCRIPT_DIR")")"
CONF_PATH="$CARDANOBI_DIR/config"
SCRIPTS_PATH="$CARDANOBI_DIR/scripts"

DEPLOY_PATH="$HOME/cardanobi-srv/api/ApiCore"

echo
echo '---------------- Getting cardanobi-identity-server systemd service ready ----------------'

cat > /tmp/run.cardanobi-api-core.service << EOF
[Unit]
Description=CardanoBI API Core
Wants=network-online.target
After=multi-user.target

[Service]
User=$USER
Type=simple
WorkingDirectory=$DEPLOY_PATH
Restart=always
RestartSec=5
LimitNOFILE=131072
ExecStart=/usr/bin/dotnet ApiCore.dll
KillSignal=SIGINT
RestartKillSignal=SIGINT
TimeoutStopSec=2
SuccessExitStatus=143
SyslogIdentifier=run.cardanobi-api-core.service
Environment=ASPNETCORE_ENVIRONMENT=Development
Environment=DOTNET_PRINT_TELEMETRY_MESSAGE=false

[Install]
WantedBy=multi-user.target
EOF

sudo mv /tmp/run.cardanobi-api-core.service /etc/systemd/system
sudo systemctl daemon-reload
sudo systemctl enable run.cardanobi-api-core.service

echo '---------------- cardanobi-api-core.service systemd service ready ----------------'
sudo systemctl status run.cardanobi-api-core.service