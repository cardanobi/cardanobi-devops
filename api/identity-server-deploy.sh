#!/bin/bash
# global variables
NOW=`date +"%Y%m%d_%H%M%S"`
SCRIPT_DIR="$(realpath "$(dirname "$0")")"
CARDANOBI_DIR="$HOME/cardanobi"
CONF_PATH="$CARDANOBI_DIR/config"
SCRIPTS_PATH="$CARDANOBI_DIR/scripts"

BUILD_PATH="$CARDANOBI_DIR/api/src/IdentityServer"
DEPLOY_PATH="$HOME/cardanobi-srv/api/IdentityServer"

echo "SCRIPT_DIR: $SCRIPT_DIR"
echo "CARDANOBI_DIR: $CARDANOBI_DIR"
echo "SCRIPTS_PATH: $SCRIPTS_PATH"
echo "DEPLOY_PATH: $DEPLOY_PATH"
echo "CURRENT_DIR: $PWD"

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

