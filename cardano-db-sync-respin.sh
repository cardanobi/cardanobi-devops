#!/bin/bash
# global variables
NOW=`date +"%Y%m%d_%H%M%S"`
SCRIPT_DIR="$(realpath "$(dirname "$0")")"
CARDANOBI_DIR="$(realpath "$(dirname "$SCRIPT_DIR")")"
CONF_PATH="$CARDANOBI_DIR/config"
SCRIPTS_PATH="$CARDANOBI_DIR/scripts"

# importing utility functions
source $SCRIPTS_PATH/utils.sh

echo "CARDANO-DB-SYNC-RESPIN STARTING..."

# make sure cardano-db-sync service is stopped
sudo systemctl stop run.cardano-db-sync.service

echo
echo '---------------- Preparing cardano-db-sync following a respin of the environment  ----------------'
INSTALL_PATH=$HOME
INSTALL_PATH=$(prompt_input_default INSTALL_PATH $INSTALL_PATH)

PGPASS_PATH=$CONF_PATH/pgpass-cardanobi
PGPASS_PATH=$(prompt_input_default PGPASS_PATH $PGPASS_PATH)

echo
echo "Details of your cardano-db-sync build:"
echo "INSTALL_PATH: $INSTALL_PATH"
echo "PGPASS_PATH: $PGPASS_PATH"
if ! promptyn "Please confirm you want to proceed? (y/n)"; then
    echo "Ok bye!"
    exit 1
fi

echo
echo "Creating the DB..."
cd cardano-db-sync
PGPASSFILE=$PGPASS_PATH scripts/postgresql-setup.sh --createdb


