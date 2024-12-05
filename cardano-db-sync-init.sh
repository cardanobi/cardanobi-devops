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

echo "CARDANO-DB-SYNC-INIT STARTING..."

# echo '---------------- secp256k1 dependency ----------------'
# ISSECP256K1=$(ldconfig -p | grep secp256k1 | wc -l)

# if [[ $ISSECP256K1 -eq 0 ]];then
#     echo "secp256k1 lib not found, installing..."
#     mkdir -p ~/download
#     cd ~/download
#     git clone https://github.com/bitcoin-core/secp256k1.git
#     cd secp256k1
#     git checkout acf5c55
#     ./autogen.sh
#     ./configure --enable-module-schnorrsig --enable-experimental
#     make
#     make check
#     sudo make install
# else
#     echo "secp256k1 lib found, no installation required."
# fi

# echo '---------------- libblst dependency ----------------'
# ISLIBBLST=$(ldconfig -p | grep libblst | wc -l)

# if [[ $ISLIBBLST -eq 0 ]];then
#     echo "libblst lib not found, installing..."
#     mkdir -p ~/download
#     cd ~/download
#     git clone https://github.com/supranational/blst
#     cd blst
#     git checkout 3dd0f80
#     ./build.sh

#     cat > libblst.pc << EOF
# prefix=/usr/local
# exec_prefix=\${prefix}
# libdir=\${exec_prefix}/lib
# includedir=\${prefix}/include

# Name: libblst
# Description: Multilingual BLS12-381 signature library
# URL: https://github.com/supranational/blst
# Version: 0.3.10
# Cflags: -I\${includedir}
# Libs: -L\${libdir} -lblst
# EOF

#     sudo cp libblst.pc /usr/local/lib/pkgconfig/
#     sudo cp bindings/blst_aux.h bindings/blst.h bindings/blst.hpp  /usr/local/include/
#     sudo cp libblst.a /usr/local/lib
#     sudo chmod 644 \
#         /usr/local/lib/libblst.* \
#         /usr/local/include/{blst.*,blst_aux.h}
# else
#     echo "secp256k1 lib found, no installation required."
# fi

# echo
# echo '---------------- Cabal dependency ----------------'
# ISCABAL=$(which cabal | wc -l)

# if [[ $ISCABAL -eq 0 ]];then
#     echo
#     echo '---------------- Cabal & GHC dependency ----------------'
#     curl --proto '=https' --tlsv1.2 -sSf https://get-ghcup.haskell.org | sh

#     # This is an interactive session make sure to start a new shell before resuming the rest of the install process below.

#     echo "Installing ghc 8.10.7"
#     ghcup install ghc 8.10.7
#     echo

#     echo "Installing cabal 3.10.1.0"
#     ghcup install cabal 3.10.1.0

#     ghcup set ghc 8.10.7
#     ghcup set cabal 3.10.1.0

#     echo "Make sure ghc and cabal points to .ghcup locations."
#     echo "If not you may have to add the below to your .bashrc:"
#     echo "   export PATH=/home/cardano/.ghcup/bin:\$PATH"
#     which cabal
#     which ghc
#     echo 

#     cabal --version
#     ghc --version

#     # Add $HOME/.local/bin to $PATH and ~/.bashrc if required
#     echo "\$PATH Before: $PATH"
#     if [[ ! ":$PATH:" == *":$HOME/.local/bin:"* ]]; then
#         echo "\$HOME/.local/bin not found in \$PATH"
#         echo "Tweaking your .bashrc"
#         echo $"if [[ ! ":'$PATH':" == *":'$HOME'/.local/bin:"* ]]; then
#         export PATH=\$HOME/.local/bin:\$PATH
#     fi" >> ~/.bashrc
#         eval "$(cat ~/.bashrc | tail -n +10)"
#     else
#         echo "\$HOME/.local/bin found in \$PATH, nothing to change here."
#     fi
#     echo "\$PATH After: $PATH"

#     echo "Starting: cabal update"
#     ~/.local/bin/cabal update
#     ~/.local/bin/cabal user-config update
#     sed -i 's/overwrite-policy:/overwrite-policy: always/g' ~/.cabal/config
#     cabal --version
#     echo "Completed: cabal update"
# else
#     echo "Cabal binary found, no installation required."
# fi

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

echo
echo "Creating the DB..."
PGPASSFILE=$PGPASS_PATH scripts/postgresql-setup.sh --createdb

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

#Config files setup
cd $INSTALL_PATH/cardanobi-db-sync
mkdir -p configs
cd configs
mkdir -p preprod
curl --remote-name-all --output-dir preprod \
    https://book.world.dev.cardano.org/environments/preprod/config.json \
    https://book.world.dev.cardano.org/environments/preprod/db-sync-config.json \
    https://book.world.dev.cardano.org/environments/preprod/submit-api-config.json \
    https://book.world.dev.cardano.org/environments/preprod/topology.json \
    https://book.world.dev.cardano.org/environments/preprod/byron-genesis.json \
    https://book.world.dev.cardano.org/environments/preprod/shelley-genesis.json \
    https://book.world.dev.cardano.org/environments/preprod/alonzo-genesis.json \
    https://book.world.dev.cardano.org/environments/preprod/conway-genesis.json

#todo - replace NodeConfigFile with correct value in db-sync-config.json