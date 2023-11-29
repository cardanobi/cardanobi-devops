#!/bin/bash
# global variables
NOW=`date +"%Y%m%d_%H%M%S"`
SCRIPT_DIR="$(realpath "$(dirname "$0")")"
BASE_DIR="$(realpath "$(dirname "$SCRIPT_DIR")")"
ROOT_DIR="$(realpath "$(dirname "$BASE_DIR")")"
CONF_PATH="$BASE_DIR/config"

echo "SCRIPT_DIR: $SCRIPT_DIR"
echo "BASE_DIR: $BASE_DIR"
echo "ROOT_DIR: $ROOT_DIR"
echo "CONF_PATH: $CONF_PATH"
echo

# importing utility functions
source $BASE_DIR/utils.sh

echo '---------------- Deploying CardanoBI Identity Admin Instance  ----------------'
echo
ROOT_BUILD_PATH="$ROOT_DIR/Duende.IdentityServer.Admin/src"
ROOT_BUILD_PATH=$(prompt_input_default ROOT_BUILD_PATH $ROOT_BUILD_PATH)

ROOT_DEPLOY_PATH="$ROOT_DIR/cardanobi-srv/api"
ROOT_DEPLOY_PATH=$(prompt_input_default ROOT_DEPLOY_PATH $ROOT_DEPLOY_PATH)

echo
echo "Details of your CardanoBI Identity Admin Instance deployment:"
echo "ROOT_BUILD_PATH: $ROOT_BUILD_PATH"
echo "ROOT_DEPLOY_PATH: $ROOT_DEPLOY_PATH"
if ! promptyn "Please confirm you want to proceed? (y/n)"; then
    echo "Ok bye!"
    exit 1
fi

# IdentityServer.Admin.Api
BUILD_PATH="$ROOT_BUILD_PATH/Skoruba.Duende.IdentityServer.Admin.Api"
DEPLOY_PATH="$ROOT_DEPLOY_PATH/IdentityServer.Admin.Api"

mkdir -p $DEPLOY_PATH

if [ -d $BUILD_PATH ]
then
    echo ""
    echo "Deploying IdentityServer.Admin.Api"
    echo "Purging target deploy path..."
    rm -rf $DEPLOY_PATH/*

    echo ""
    echo "Building the solution..."
    cd $BUILD_PATH
    # dotnet publish -c Release -o $DEPLOY_PATH /p:EnvironmentName=Production
    dotnet publish -c Debug -o $DEPLOY_PATH /p:EnvironmentName=Development

    # dotnet publish -c Release -o $DEPLOY_PATH
    # dotnet publish -c Debug -o $DEPLOY_PATH
else
    echo
    echo "Cannot locate BUILD_PATH: $BUILD_PATH"
    exit
fi

# IdentityServer.Admin.STS
BUILD_PATH="$ROOT_BUILD_PATH/Skoruba.Duende.IdentityServer.STS.Identity"
DEPLOY_PATH="$ROOT_DEPLOY_PATH/IdentityServer.Admin.STS"

# BUILD_PATH="$CARDANOBI_DIR/api/src/Duende.IdentityServer.Admin/src/Skoruba.Duende.IdentityServer.STS.Identity"
# DEPLOY_PATH="$HOME/cardanobi-srv/api/IdentityServer.Admin.STS"

mkdir -p $DEPLOY_PATH

if [ -d $BUILD_PATH ]
then
    echo ""
    echo "Deploying IdentityServer.Admin.STS"
    echo "Purging target deploy path..."
    rm -rf $DEPLOY_PATH/*

    echo ""
    echo "Building the solution..."
    cd $BUILD_PATH
    # dotnet publish -c Release -o $DEPLOY_PATH /p:EnvironmentName=Production
    dotnet publish -c Debug -o $DEPLOY_PATH /p:EnvironmentName=Development

    # dotnet publish -c Release -o $DEPLOY_PATH
    # dotnet publish -c Debug -o $DEPLOY_PATH
else
    echo
    echo "Cannot locate BUILD_PATH: $BUILD_PATH"
    exit
fi

# IdentityServer.Admin
BUILD_PATH="$ROOT_BUILD_PATH/Skoruba.Duende.IdentityServer.Admin"
DEPLOY_PATH="$ROOT_DEPLOY_PATH/IdentityServer.Admin"

# BUILD_PATH="$CARDANOBI_DIR/api/src/Duende.IdentityServer.Admin/src/Skoruba.Duende.IdentityServer.Admin"
# DEPLOY_PATH="$HOME/cardanobi-srv/api/IdentityServer.Admin"

mkdir -p $DEPLOY_PATH

if [ -d $BUILD_PATH ]
then
    echo ""
    echo "Deploying IdentityServer.Admin"
    echo "Purging target deploy path..."
    rm -rf $DEPLOY_PATH/*

    echo ""
    echo "Building the solution..."
    cd $BUILD_PATH
    # dotnet publish -c Release -o $DEPLOY_PATH /p:EnvironmentName=Production
    dotnet publish -c Debug -o $DEPLOY_PATH /p:EnvironmentName=Development

    # dotnet publish -c Release -o $DEPLOY_PATH
    # dotnet publish -c Debug -o $DEPLOY_PATH
else
    echo
    echo "Cannot locate BUILD_PATH: $BUILD_PATH"
    exit
fi
