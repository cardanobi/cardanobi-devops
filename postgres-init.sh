#!/bin/bash
# global variables
NOW=`date +"%Y%m%d_%H%M%S"`
SCRIPT_DIR="$(realpath "$(dirname "$0")")"
BASE_DIR="$(realpath "$(dirname "$SCRIPT_DIR")")"
CONF_PATH="$SCRIPT_DIR/config"

echo "SCRIPT_DIR: $SCRIPT_DIR"
echo "BASE_DIR: $BASE_DIR"
echo "CONF_PATH: $CONF_PATH"
echo

# importing utility functions
source $SCRIPT_DIR/utils.sh

echo "POSTGRES-INIT STARTING..."
echo

# Debian/Ubuntu install
wget --quiet -O - https://www.postgresql.org/media/keys/ACCC4CF8.asc | sudo apt-key add -
RELEASE=$(lsb_release -cs)

echo "RELEASE: $RELEASE"
echo "deb [arch=amd64] http://apt.postgresql.org/pub/repos/apt/ ${RELEASE}"-pgdg main | sudo tee  /etc/apt/sources.list.d/pgdg.list

echo
if ! promptyn "Ready to continue? (y/n)"; then
    echo "Ok bye!"
    exit 1
fi

sudo apt-get update
sudo apt-get -y install postgresql-14
# sudo apt-get -y install postgresql-14 postgresql-server-dev-14 postgresql-contrib libghc-hdbc-postgresql-dev
sudo systemctl restart postgresql
sudo systemctl enable postgresql

echo
echo "Setting up a user in postgres:"
echo "Please now create a superuser:"

# Switching to the postgres user and executing the psql commands
sudo -u postgres psql <<'EOF'
CREATE ROLE cardano SUPERUSER LOGIN;
ALTER USER cardano PASSWORD 'cardano';
\q
EOF

echo "Managing postgres data file config..."
PSQL_CONF_FILE=$(ps -eaf | grep postgres | grep config_file | awk -F "config_file=" '{ print $2 }')
CURRENT_DATA_FILE_LOC=$(grep data_directory $PSQL_CONF_FILE | awk -F "'" '{ print $2 }')

PSQL_CONF_FILE=$(prompt_input_default PSQL_CONF_FILE $PSQL_CONF_FILE)
CURRENT_DATA_FILE_LOC=$(prompt_input_default CURRENT_DATA_FILE_LOC $CURRENT_DATA_FILE_LOC)
TARGET_DATA_FILE_LOC_WITHOUT_MAIN=$BASE_DIR/postgresql/14/main
TARGET_DATA_FILE_LOC_WITHOUT_MAIN=$(prompt_input_default TARGET_DATA_FILE_LOC_WITHOUT_MAIN $TARGET_DATA_FILE_LOC_WITHOUT_MAIN)

echo
echo "Details of your postgres data file setup:"
echo "PSQL_CONF_FILE: $PSQL_CONF_FILE"
echo "CURRENT_DATA_FILE_LOC: $CURRENT_DATA_FILE_LOC"
echo "TARGET_DATA_FILE_LOC_WITHOUT_MAIN: $TARGET_DATA_FILE_LOC_WITHOUT_MAIN"
if ! promptyn "Please confirm you want to proceed? (y/n)"; then
    echo "Ok bye!"
    exit 1
fi

mkdir -p $TARGET_DATA_FILE_LOC_WITHOUT_MAIN

sudo systemctl stop postgresql
sudo systemctl status postgresql

if ! promptyn "Ok to proceed? (y/n)"; then
    echo "Ok bye!"
    exit 1
fi

echo "Changing the config file..."
# sudo sed -i "s|data_directory = '${CURRENT_DATA_FILE_LOC}'|data_directory = '${TARGET_DATA_FILE_LOC_WITHOUT_MAIN}/main'|g" $PSQL_CONF_FILE 

# Update data_directory
sudo sed -i "s|^[#]*[ \t]*data_directory[ \t]*=.*|data_directory = '${TARGET_DATA_FILE_LOC_WITHOUT_MAIN}/main'|g" $PSQL_CONF_FILE

# Update wal_level
sudo sed -i "s|^[#]*[ \t]*wal_level[ \t]*=.*|wal_level = minimal|g" $PSQL_CONF_FILE

# Update max_wal_senders
sudo sed -i "s|^[#]*[ \t]*max_wal_senders[ \t]*=.*|max_wal_senders = 0|g" $PSQL_CONF_FILE

# Update synchronous_commit
sudo sed -i "s|^[#]*[ \t]*synchronous_commit[ \t]*=.*|synchronous_commit = off|g" $PSQL_CONF_FILE

# Update maintenance_work_mem
sudo sed -i "s|^[#]*[ \t]*maintenance_work_mem[ \t]*=.*|maintenance_work_mem = 500MB|g" $PSQL_CONF_FILE

# Update max_parallel_maintenance_workers
sudo sed -i "s|^[#]*[ \t]*max_parallel_maintenance_workers[ \t]*=.*|max_parallel_maintenance_workers = 2|g" $PSQL_CONF_FILE



if ! promptyn "Config changed, ok to proceed? (y/n)"; then
    echo "Ok bye!"
    exit 1
fi

sudo rsync -av $CURRENT_DATA_FILE_LOC $TARGET_DATA_FILE_LOC_WITHOUT_MAIN

if ! promptyn "Rsync done, ok restart postgres? (y/n)"; then
    echo "Ok bye!"
    exit 1
fi

sudo systemctl start postgresql

echo "Please check current data directory..."
echo "sudo -u postgres psql"
echo "SHOW data_directory;"
echo
echo "POSTGRES-INIT COMPLETED!"
