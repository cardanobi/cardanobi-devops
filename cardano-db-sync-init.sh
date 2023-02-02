#!/bin/bash
# global variables
NOW=`date +"%Y%m%d_%H%M%S"`
SCRIPT_DIR="$(realpath "$(dirname "$0")")"
CARDANOBI_DIR="$(realpath "$(dirname "$SCRIPT_DIR")")"
CONF_PATH="$CARDANOBI_DIR/config"
SCRIPTS_PATH="$CARDANOBI_DIR/scripts"

# importing utility functions
source $SCRIPTS_PATH/utils.sh

echo "CARDANO-DB-SYNC-INIT STARTING..."

echo '---------------- secp256k1 dependency ----------------'
ISSECP256K1=$(ldconfig -p | grep secp256k1 | wc -l)

if [[ $ISSECP256K1 -eq 0 ]];then
    echo "secp256k1 lib not found, installing..."
    mkdir -p ~/download
    cd ~/download
    git clone https://github.com/bitcoin-core/secp256k1.git
    cd secp256k1
    git reset --hard ac83be33d0956faf6b7f61a60ab524ef7d6a473a
    ./autogen.sh
    ./configure --prefix=/usr --enable-module-schnorrsig --enable-experimental
    make
    make check
    sudo make install
else
    echo "secp256k1 lib found, no installation required."
fi

echo
echo '---------------- Cabal dependency ----------------'
ISCABAL=$(which cabal | wc -l)

if [[ $ISCABAL -eq 0 ]];then
    echo
    echo '---------------- Installing Cabal ----------------'
    # Download most recent version (check this is still the right version here: https://www.haskell.org/cabal/download.html)
    mkdir -p ~/download/cabal
    cd ~/download/cabal
    wget https://downloads.haskell.org/~cabal/cabal-install-3.4.0.0/cabal-install-3.4.0.0-x86_64-ubuntu-16.04.tar.xz
    tar -xf cabal-install-3.4.0.0-x86_64-ubuntu-16.04.tar.xz
    mkdir -p ~/.local/bin
    cp cabal ~/.local/bin/

    # Add $HOME/.local/bin to $PATH and ~/.bashrc if required
    echo "\$PATH Before: $PATH"
    if [[ ! ":$PATH:" == *":$HOME/.local/bin:"* ]]; then
        echo "\$HOME/.local/bin not found in \$PATH"
        echo "Tweaking your .bashrc"
        echo $"if [[ ! ":'$PATH':" == *":'$HOME'/.local/bin:"* ]]; then
        export PATH=\$HOME/.local/bin:\$PATH
    fi" >> ~/.bashrc
        eval "$(cat ~/.bashrc | tail -n +10)"
    else
        echo "\$HOME/.local/bin found in \$PATH, nothing to change here."
    fi
    echo "\$PATH After: $PATH"

    echo "Starting: cabal update"
    ~/.local/bin/cabal update
    ~/.local/bin/cabal user-config update
    sed -i 's/overwrite-policy:/overwrite-policy: always/g' ~/.cabal/config
    cabal --version
    echo "Completed: cabal update"
else
    echo "Cabal binary found, no installation required."
fi

echo
echo '---------------- Building cardano-db-sync with cabal ----------------'
INSTALL_PATH=$HOME
INSTALL_PATH=$(prompt_input_default INSTALL_PATH $INSTALL_PATH)

PGPASS_PATH=$CONF_PATH/pgpass-cardanobi
PGPASS_PATH=$(prompt_input_default PGPASS_PATH $PGPASS_PATH)

LATESTTAG=$(curl -s https://api.github.com/repos/input-output-hk/cardano-db-sync/releases/latest | jq -r .tag_name)
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
git clone https://github.com/input-output-hk/cardano-db-sync
cd cardano-db-sync

echo
echo "Creating the DB..."
PGPASSFILE=$PGPASS_PATH scripts/postgresql-setup.sh --createdb

git fetch --all --tags
git checkout "tags/$LATESTTAG"

echo
git describe --tags

echo
if ! promptyn "Is this the correct tag? (y/n)"; then
    echo "Ok bye!"
    exit 1
fi

echo
echo "Building cardano-db-sync, tag $LATESTTAG:"
cabal build cardano-db-sync 2>&1 | tee /tmp/build.cardano-db-sync.log

cp -p "$($SCRIPTS_PATH/bin_path.sh cardano-db-sync)" ~/.local/bin/
cardano-db-sync --version

#Moving schema migration files to our work directory
cp $INSTALL_PATH/cardano-db-sync/schema/* ~/db-sync/schema
