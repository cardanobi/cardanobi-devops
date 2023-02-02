#!/bin/bash
# global variables
NOW=`date +"%Y%m%d_%H%M%S"`
SCRIPT_DIR="$(realpath "$(dirname "$0")")"
CARDANOBI_DIR="$(realpath "$(dirname "$SCRIPT_DIR")")"
CONF_PATH="$CARDANOBI_DIR/config"
SCRIPTS_PATH="$CARDANOBI_DIR/scripts"

DEPLOY_PATH="$HOME/cardanobi-srv/api/IdentityServer.Admin.Api"
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


DEPLOY_PATH="$HOME/cardanobi-srv/api/IdentityServer.Admin.STS"
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


DEPLOY_PATH="$HOME/cardanobi-srv/api/IdentityServer.Admin"
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