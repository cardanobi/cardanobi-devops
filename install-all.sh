#!/bin/bash
# global variables
NOW=`date +"%Y%m%d_%H%M%S"`
SCRIPT_DIR="$(realpath "$(dirname "$0")")"
CONF_PATH="$SCRIPT_DIR/config"

echo "SCRIPT_DIR: $SCRIPT_DIR"
echo "CONF_PATH: $CONF_PATH"

# importing utility functions
source $SCRIPT_DIR/utils.sh

echo "CARDANOBI INSTALL ALL STARTING..."
echo

echo "SCANNING WHAT NEEDS DOING..."
echo

DOTNET_PATH=`which dotnet`
DOTNET_VERSION=`dotnet --version`
DOTNET_CHECK=true
DOTNET_CHECK_DESC="PASS"
if [[ $DOTNET_PATH == "" || $DOTNET_VERSION < "5.0" ]]; then
    DOTNET_CHECK=false
    DOTNET_CHECK_DESC="FAILED"
fi

echo "DOTNET CHECK: $DOTNET_CHECK_DESC"
echo "  path: $DOTNET_PATH"
echo "  version: $DOTNET_VERSION"
echo

CARDANO_NODE_PATH=`which cardano-node`
CARDANO_NODE_VERSION=`cardano-node --version | head -1 | awk '{print $2}'`
CARDANO_NODE_CHECK=true
CARDANO_NODE_CHECK_DESC="PASS"
if [[ $CARDANO_NODE_PATH == "" || $CARDANO_NODE_VERSION < "1.35" ]]; then
    CARDANO_NODE_CHECK=false
    CARDANO_NODE_CHECK_DESC="FAILED"
fi

echo "CARDANO NODE CHECK: $CARDANO_NODE_CHECK_DESC"
echo "  path: $CARDANO_NODE_PATH"
echo "  version: $CARDANO_NODE_VERSION"
echo

CARDANO_DB_SYNC_PATH=`which cardano-db-sync`
CARDANO_DB_SYNC_VERSION=`cardano-db-sync --version | head -1 | awk '{print $2}'`
CARDANO_DB_SYNC_CHECK=true
CARDANO_DB_SYNC_CHECK_DESC="PASS"
if [[ $CARDANO_DB_SYNC_PATH == "" || $CARDANO_DB_SYNC_VERSION < "13.0" ]]; then
    CARDANO_DB_SYNC_CHECK=false
    CARDANO_DB_SYNC_CHECK_DESC="FAILED"
fi

echo "CARDANO DB SYNC CHECK: $CARDANO_DB_SYNC_CHECK_DESC"
echo "  path: $CARDANO_DB_SYNC_PATH"
echo "  version: $CARDANO_DB_SYNC_VERSION"
echo

CARDANO_DB_SYNC_SERVICE_PATH=`grep -rnws -m1 /etc/systemd/system/*.service -e db-sync | awk -F: '{print $1}'`
CARDANO_DB_SYNC_SERVICE_CHECK=true
CARDANO_DB_SYNC_SERVICE_CHECK_DESC="PASS"
if [[ $CARDANO_DB_SYNC_SERVICE_PATH == "" ]]; then
    CARDANO_DB_SYNC_SERVICE_CHECK=false
    CARDANO_DB_SYNC_SERVICE_CHECK_DESC="FAILED"
fi

echo "CARDANO DB SYNC SERVICE CHECK: $CARDANO_DB_SYNC_SERVICE_CHECK_DESC"
echo "  path: $CARDANO_DB_SYNC_SERVICE_PATH"
echo

NGINX_PATH=`which nginx`
NGINX_CHECK=true
NGINX_CHECK_DESC="PASS"
if [[ $NGINX_PATH == "" ]]; then
    NGINX_CHECK=false
    NGINX_CHECK_DESC="FAILED"
fi

echo "NGINX CHECK: $NGINX_CHECK_DESC"
echo "  path: $NGINX_PATH"
echo


echo "CARDANOBI INSTALL ALL COMPLETE."