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

echo '---------------- Deploying CardanoBI Identity Admin Instance Service  ----------------'
echo
ROOT_DEPLOY_PATH="$HOME/cardanobi-srv/api"
ROOT_DEPLOY_PATH=$(prompt_input_default ROOT_DEPLOY_PATH $ROOT_DEPLOY_PATH)

echo
echo "Details of your CardanoBI Identity Service deployment:"
echo "ROOT_DEPLOY_PATH: $ROOT_DEPLOY_PATH"
if ! promptyn "Please confirm you want to proceed? (y/n)"; then
    echo "Ok bye!"
    exit 1
fi

DEPLOY_PATH="$ROOT_DEPLOY_PATH/IdentityServer.Admin.Api"
echo
echo '---------------- Getting cardanobi-identity-server-admin-api systemd service ready ----------------'

cat > /tmp/run.cardanobi-identity-server-admin-api.service << EOF
[Unit]
Description=CardanoBI Identity Server Admin Api
Wants=network-online.target
After=multi-user.target

[Service]
User=$USER
Type=simple
WorkingDirectory=$DEPLOY_PATH
Restart=always
RestartSec=5
LimitNOFILE=131072
ExecStart=/usr/bin/dotnet Skoruba.Duende.IdentityServer.Admin.Api.dll
KillSignal=SIGINT
RestartKillSignal=SIGINT
TimeoutStopSec=2
SuccessExitStatus=143
SyslogIdentifier=run.cardanobi-identity-server-admin-api.service
Environment=ASPNETCORE_ENVIRONMENT=Development
Environment=DOTNET_PRINT_TELEMETRY_MESSAGE=false

[Install]
WantedBy=multi-user.target
EOF

sudo mv /tmp/run.cardanobi-identity-server-admin-api.service /etc/systemd/system
sudo systemctl daemon-reload
sudo systemctl enable run.cardanobi-identity-server-admin-api.service

echo '---------------- cardanobi-identity-server-admin-api.service systemd service ready ----------------'
sudo systemctl status run.cardanobi-identity-server-admin-api.service


DEPLOY_PATH="$ROOT_DEPLOY_PATH/IdentityServer.Admin.STS"
echo
echo '---------------- Getting cardanobi-identity-server-admin-sts systemd service ready ----------------'

cat > /tmp/run.cardanobi-identity-server-admin-sts.service << EOF
[Unit]
Description=CardanoBI Identity Server Admin STS
Wants=network-online.target
After=multi-user.target

[Service]
User=$USER
Type=simple
WorkingDirectory=$DEPLOY_PATH
Restart=always
RestartSec=5
LimitNOFILE=131072
ExecStart=/usr/bin/dotnet Skoruba.Duende.IdentityServer.STS.Identity.dll
KillSignal=SIGINT
RestartKillSignal=SIGINT
TimeoutStopSec=2
SuccessExitStatus=143
SyslogIdentifier=run.cardanobi-identity-server-admin-sts.service
Environment=ASPNETCORE_ENVIRONMENT=Development
Environment=DOTNET_PRINT_TELEMETRY_MESSAGE=false

[Install]
WantedBy=multi-user.target
EOF

sudo mv /tmp/run.cardanobi-identity-server-admin-sts.service /etc/systemd/system
sudo systemctl daemon-reload
sudo systemctl enable run.cardanobi-identity-server-admin-sts.service

echo '---------------- cardanobi-identity-server-admin-sts.service systemd service ready ----------------'
sudo systemctl status run.cardanobi-identity-server-admin-sts.service


DEPLOY_PATH="$ROOT_DEPLOY_PATH/IdentityServer.Admin"
echo
echo '---------------- Getting cardanobi-identity-server-admin systemd service ready ----------------'

cat > /tmp/run.cardanobi-identity-server-admin.service << EOF
[Unit]
Description=CardanoBI Identity Server Admin
Wants=network-online.target
After=multi-user.target

[Service]
User=$USER
Type=simple
WorkingDirectory=$DEPLOY_PATH
Restart=always
RestartSec=5
LimitNOFILE=131072
ExecStart=/usr/bin/dotnet Skoruba.Duende.IdentityServer.Admin.dll
KillSignal=SIGINT
RestartKillSignal=SIGINT
TimeoutStopSec=2
SuccessExitStatus=143
SyslogIdentifier=run.cardanobi-identity-server-admin.service
Environment=ASPNETCORE_ENVIRONMENT=Development
Environment=DOTNET_PRINT_TELEMETRY_MESSAGE=false

[Install]
WantedBy=multi-user.target
EOF

sudo mv /tmp/run.cardanobi-identity-server-admin.service /etc/systemd/system
sudo systemctl daemon-reload
sudo systemctl enable run.cardanobi-identity-server-admin.service

echo '---------------- cardanobi-identity-server-admin.service systemd service ready ----------------'
sudo systemctl status run.cardanobi-identity-server-admin.service