#!/bin/bash
# global variables
NOW=`date +"%Y%m%d_%H%M%S"`
SCRIPT_DIR="$(realpath "$(dirname "$0")")"
CARDANOBI_DIR="$(realpath "$(dirname "$SCRIPT_DIR")")"
CONF_PATH="$CARDANOBI_DIR/config"
SCRIPTS_PATH="$CARDANOBI_DIR/scripts"

echo
echo '---------------- Getting cardano-db-sync systemd service ready ----------------'

cat > $HOME/db-sync/run.cardano-db-sync.service << EOF
[Unit]
Description=Cardano DB Sync Run Script
Wants=network-online.target
After=multi-user.target

[Service]
User=$USER
Type=simple
WorkingDirectory=$HOME/db-sync
Restart=always
RestartSec=5
LimitNOFILE=131072
ExecStart=/bin/bash -c '$HOME/cardanobi/scripts/run.cardano-db-sync.sh'
KillSignal=SIGINT
RestartKillSignal=SIGINT
TimeoutStopSec=2
SuccessExitStatus=143
SyslogIdentifier=run.cardano-db-sync

[Install]
WantedBy=multi-user.target
EOF

sudo mv $HOME/db-sync/run.cardano-db-sync.service /etc/systemd/system
sudo systemctl daemon-reload
sudo systemctl enable run.cardano-db-sync

echo '---------------- cardano-db-sync systemd service ready ----------------'
sudo systemctl status run.cardano-db-sync