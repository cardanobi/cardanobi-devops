#!/bin/bash
# global variables
NOW=`date +"%Y%m%d_%H%M%S"`
SCRIPT_DIR="$(realpath "$(dirname "$0")")"
CARDANOBI_DIR="$(realpath "$(dirname "$SCRIPT_DIR")")"
CONF_PATH="$CARDANOBI_DIR/config"
SCRIPTS_PATH="$CARDANOBI_DIR/scripts"
NODE_ENV="preprod"

# loading important environment variables by forcing .bashrc to be reloaded
# useful as this script will be run as a systemd service for which no env variable are preloaded
eval "$(cat ~/.bashrc | tail -n +10)"

LEDGER_STATE_DIR=~/db-sync/ledger-state/$NODE_ENV
SCHEMA_DIR=~/db-sync/schema

mkdir -p $LEDGER_STATE_DIR
mkdir -p $SCHEMA_DIR

PGPASSFILE=$CONF_PATH/pgpass-cardanobi cardano-db-sync \
    --config $CONF_PATH/preprod-config.yaml \
    --socket-path $CARDANO_NODE_SOCKET_PATH \
    --state-dir $LEDGER_STATE_DIR \
    --schema-dir $SCHEMA_DIR
