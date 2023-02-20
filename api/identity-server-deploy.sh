#!/bin/bash
# global variables
NOW=`date +"%Y%m%d_%H%M%S"`
SCRIPT_DIR="$(realpath "$(dirname "$0")")"
BASE_DIR="$(realpath "$(dirname "$SCRIPT_DIR")")"
CONF_PATH="$BASE_DIR/config"

echo "SCRIPT_DIR: $SCRIPT_DIR"
echo "BASE_DIR: $BASE_DIR"
echo "CONF_PATH: $CONF_PATH"
echo

# importing utility functions
source $BASE_DIR/utils.sh

echo '---------------- Deploying CardanoBI Identity Instance  ----------------'
echo
BUILD_PATH="$HOME/cardanobi-backend-identity/src/IdentityServer"
BUILD_PATH=$(prompt_input_default BUILD_PATH $BUILD_PATH)

DEPLOY_PATH="$HOME/cardanobi-srv/api/IdentityServer"
DEPLOY_PATH=$(prompt_input_default DEPLOY_PATH $DEPLOY_PATH)

echo
echo "Details of your CardanoBI Identity Instance deployment:"
echo "BUILD_PATH: $BUILD_PATH"
echo "DEPLOY_PATH: $DEPLOY_PATH"
if ! promptyn "Please confirm you want to proceed? (y/n)"; then
    echo "Ok bye!"
    exit 1
fi

mkdir -p $DEPLOY_PATH

if [ -d $BUILD_PATH ]
then
    echo ""
    echo "Purging target deploy path..."
    rm -rf $DEPLOY_PATH/*

    echo ""
    echo "Building the solution..."
    cd $BUILD_PATH
    # dotnet publish -c Release -o $DEPLOY_PATH /p:EnvironmentName=Production
    # dotnet publish -c Debug -o $DEPLOY_PATH /p:EnvironmentName=Development

    dotnet publish -c Release -o $DEPLOY_PATH
    # dotnet publish -c Debug -o $DEPLOY_PATH
else
    echo
    echo "Cannot locate BUILD_PATH: $BUILD_PATH"
    exit
fi

