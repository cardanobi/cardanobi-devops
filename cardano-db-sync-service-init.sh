#!/bin/bash
# global variables
NOW=`date +"%Y%m%d_%H%M%S"`
SCRIPT_DIR="$(realpath "$(dirname "$0")")"
BASE_DIR="$(realpath "$(dirname "$SCRIPT_DIR")")"
CONF_PATH="$SCRIPT_DIR/config"
CARDANO_ENV=${SPOT_PATH##*/}

echo "SCRIPT_DIR: $SCRIPT_DIR"
echo "BASE_DIR: $BASE_DIR"
echo "CONF_PATH: $CONF_PATH"
echo "CARDANO_ENV: $CARDANO_ENV"
echo

# importing utility functions
source $SCRIPT_DIR/utils.sh

# cardano-db-sync service setup process
# CARDANO_ENV="mainnet"
CARDANO_ENV=$(prompt_input_default CARDANO_ENV $CARDANO_ENV)

CARDANO_DB_SYNC_PATH="$BASE_DIR/cardano-db-sync"
CARDANO_DB_SYNC_PATH=$(prompt_input_default CARDANO_DB_SYNC_PATH $CARDANO_DB_SYNC_PATH)

CARDANOBI_DB_SYNC_PATH="$BASE_DIR/cardanobi-db-sync"
CARDANOBI_DB_SYNC_PATH=$(prompt_input_default CARDANOBI_DB_SYNC_PATH $CARDANOBI_DB_SYNC_PATH)

echo
echo "Details of your cardano-db-sync service install:"
echo "CARDANO_ENV: $CARDANO_ENV"
echo "CARDANO_DB_SYNC_PATH: $CARDANO_DB_SYNC_PATH"
echo "CARDANOBI_DB_SYNC_PATH: $CARDANOBI_DB_SYNC_PATH"
if ! promptyn "Please confirm you want to proceed? (y/n)"; then
    echo "Ok bye!"
    exit 1
fi

#Moving schema migration files to our work directory
mkdir -p $CARDANOBI_DB_SYNC_PATH/schema
cp $CARDANO_DB_SYNC_PATH/schema/* $CARDANOBI_DB_SYNC_PATH/schema

cp $SCRIPT_DIR/run.cardano-db-sync-$CARDANO_ENV.sh $CARDANOBI_DB_SYNC_PATH/run.cardano-db-sync.sh
cp $SCRIPT_DIR/config/pgpass-cardanobi $CARDANOBI_DB_SYNC_PATH
cp $SCRIPT_DIR/config/$CARDANO_ENV-config.yaml $CARDANOBI_DB_SYNC_PATH

echo
echo '---------------- Getting cardano-db-sync systemd service ready ----------------'

cat > $CARDANOBI_DB_SYNC_PATH/run.cardano-db-sync.service << EOF
[Unit]
Description=Cardano DB Sync Run Script
Wants=network-online.target
After=multi-user.target

[Service]
User=$USER
Type=simple
WorkingDirectory=$CARDANOBI_DB_SYNC_PATH
Restart=always
RestartSec=5
LimitNOFILE=131072
ExecStart=/bin/bash -c '$CARDANOBI_DB_SYNC_PATH/run.cardano-db-sync.sh'
KillSignal=SIGINT
RestartKillSignal=SIGINT
TimeoutStopSec=2
SuccessExitStatus=143
SyslogIdentifier=run.cardano-db-sync

[Install]
WantedBy=multi-user.target
EOF

sudo mv $CARDANOBI_DB_SYNC_PATH/run.cardano-db-sync.service /etc/systemd/system
sudo systemctl daemon-reload
sudo systemctl enable run.cardano-db-sync

echo '---------------- cardano-db-sync systemd service ready ----------------'
sudo systemctl status run.cardano-db-sync