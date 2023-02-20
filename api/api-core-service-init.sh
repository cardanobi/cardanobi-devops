#!/bin/bash
# global variables
NOW=`date +"%Y%m%d_%H%M%S"`
SCRIPT_DIR="$(realpath "$(dirname "$0")")"
BASE_DIR="$(realpath "$(dirname "$SCRIPT_DIR")")"
CONF_PATH="$BASE_DIR/config"

echo "SCRIPT_DIR: $SCRIPT_DIR"
echo "BASE_DIR: $BASE_DIR"
echo "CONF_PATH: $CONF_PATH"
echo

# importing utility functions
source $BASE_DIR/utils.sh

echo '---------------- Deploying CardanoBI API Instance Service  ----------------'
echo
DEPLOY_PATH="$HOME/cardanobi-srv/api/ApiCore"
DEPLOY_PATH=$(prompt_input_default DEPLOY_PATH $DEPLOY_PATH)

echo
echo "Details of your CardanoBI API Service deployment:"
echo "DEPLOY_PATH: $DEPLOY_PATH"
if ! promptyn "Please confirm you want to proceed? (y/n)"; then
    echo "Ok bye!"
    exit 1
fi

echo
echo '---------------- Getting cardanobi-api-core systemd service ready ----------------'

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