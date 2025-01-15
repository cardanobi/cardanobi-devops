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

echo "CARDANO-DB-SYNC-UPDATE STARTING..."

echo
echo '---------------- Building cardano-db-sync with cabal ----------------'
INSTALL_PATH=$BASE_DIR
INSTALL_PATH=$(prompt_input_default INSTALL_PATH $INSTALL_PATH)

PGPASS_PATH=$CONF_PATH/pgpass-cardanobi
PGPASS_PATH=$(prompt_input_default PGPASS_PATH $PGPASS_PATH)

LATESTTAG=$(curl -s https://api.github.com/repos/IntersectMBO/cardano-db-sync/releases/latest | jq -r .tag_name)
LATESTTAG=$(prompt_input_default CHECKOUT_TAG $LATESTTAG)

echo
echo "Details of your cardano-db-sync build:"
echo "INSTALL_PATH: $INSTALL_PATH"
echo "PGPASS_PATH: $PGPASS_PATH"
echo "LATESTTAG: $LATESTTAG"
if ! promptyn "Please confirm you want to proceed? (y/n)"; then
    echo "Ok bye!"
    exit 1
fi

echo
echo "Getting the source code.."
mkdir -p $INSTALL_PATH
cd $INSTALL_PATH
git clone https://github.com/IntersectMBO/cardano-db-sync
cd cardano-db-sync

# echo
# echo "Creating the DB..."
# PGPASSFILE=$PGPASS_PATH scripts/postgresql-setup.sh --createdb

git fetch --all --tags
# git checkout "tags/$LATESTTAG"
git checkout tags/$LATESTTAG

# echo "with-compiler: ghc-8.10.7" >> cabal.project.local
echo "with-compiler: ghc-9.6.3" >> cabal.project.local

echo
git describe --tags

echo
if ! promptyn "Is this the correct tag? (y/n)"; then
    echo "Ok bye!"
    exit 1
fi

echo
echo "Building cardano-db-sync, tag $LATESTTAG:"
sudo apt install pkg-config libpq-dev
cabal update

cabal build cardano-db-sync 2>&1 | tee /tmp/build.cardano-db-sync.log

cp -p "$($SCRIPT_DIR/bin_path.sh cardano-db-sync $INSTALL_PATH/cardano-db-sync)" ~/.local/bin/
cardano-db-sync --version

#Moving schema migration files to our work directory
cp $INSTALL_PATH/cardano-db-sync/schema/*  $INSTALL_PATH/cardanobi-db-sync/schema
