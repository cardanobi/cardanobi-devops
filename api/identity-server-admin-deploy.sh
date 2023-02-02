#!/bin/bash
# global variables
NOW=`date +"%Y%m%d_%H%M%S"`
SCRIPT_DIR="$(realpath "$(dirname "$0")")"
CARDANOBI_DIR="$HOME/cardanobi"
CONF_PATH="$CARDANOBI_DIR/config"
SCRIPTS_PATH="$CARDANOBI_DIR/scripts"

echo "SCRIPT_DIR: $SCRIPT_DIR"
echo "CARDANOBI_DIR: $CARDANOBI_DIR"
echo "SCRIPTS_PATH: $SCRIPTS_PATH"
echo "CURRENT_DIR: $PWD"

# IdentityServer.Admin.Api
BUILD_PATH="$CARDANOBI_DIR/api/src/Duende.IdentityServer.Admin/src/Skoruba.Duende.IdentityServer.Admin.Api"
DEPLOY_PATH="$HOME/cardanobi-srv/api/IdentityServer.Admin.Api"

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
BUILD_PATH="$CARDANOBI_DIR/api/src/Duende.IdentityServer.Admin/src/Skoruba.Duende.IdentityServer.STS.Identity"
DEPLOY_PATH="$HOME/cardanobi-srv/api/IdentityServer.Admin.STS"

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
BUILD_PATH="$CARDANOBI_DIR/api/src/Duende.IdentityServer.Admin/src/Skoruba.Duende.IdentityServer.Admin"
DEPLOY_PATH="$HOME/cardanobi-srv/api/IdentityServer.Admin"

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
