#!/bin/bash

if [[ $# -eq 1 && ! $1 == "" ]];then 
    PARAM=$1; 

    if [[ $PARAM != "stop" && $PARAM != "start" && $PARAM != "stop-admin" && $PARAM != "start-admin" ]];then
        echo -e "This script expects the following parameters:\n\tUsage: $0 {start} (optional) {start-admin} (optional) {stop} (optional) {stop-admin} (optional)"; 
        exit 2; 
    fi
fi

echo "Checking running status for CardanoBI API key services:"
echo

STATUS=$(sudo systemctl status run.cardano-db-sync.service | head -3 | tail -1 | awk '{ print $2 }')
if [[ $STATUS == "active" ]];then
    tput setaf 2; sudo systemctl status run.cardano-db-sync.service | head -3

    if [[ $PARAM == "stop" ]];then
        echo "Stopping service..."
        sudo systemctl stop run.cardano-db-sync.service
    fi
else
    tput setaf 1; sudo systemctl status run.cardano-db-sync.service | head -3

    if [[ $PARAM == "start" ]];then
        echo "Starting service..."
        sudo systemctl start run.cardano-db-sync.service
    fi
fi
echo

STATUS=$(sudo systemctl status run.cardanobi-api-core.service | head -3 | tail -1 | awk '{ print $2 }')
if [[ $STATUS == "active" ]]; then
    tput setaf 2; sudo systemctl status run.cardanobi-api-core.service | head -3

    if [[ $PARAM == "stop" ]];then
        echo "Stopping service..."
        sudo systemctl stop run.cardanobi-api-core.service
    fi
else
    tput setaf 1; sudo systemctl status run.cardanobi-api-core.service | head -3

    if [[ $PARAM == "start" ]];then
        echo "Starting service..."
        sudo systemctl start run.cardanobi-api-core.service
    fi
fi
echo

STATUS=$(sudo systemctl status run.cardanobi-identity-server-admin-api.service | head -3 | tail -1 | awk '{ print $2 }')
if [[ $STATUS == "active" ]];then
    tput setaf 2; sudo systemctl status run.cardanobi-identity-server-admin-api.service | head -3

    if [[ $PARAM == "stop" || $PARAM == "stop-admin" ]];then
        echo "Stopping service..."
        sudo systemctl stop run.cardanobi-identity-server-admin-api.service
    fi
else
    tput setaf 1; sudo systemctl status run.cardanobi-identity-server-admin-api.service | head -3

    if [[ $PARAM == "start"|| $PARAM == "start-admin"  ]];then
        echo "Starting service..."
        sudo systemctl start run.cardanobi-identity-server-admin-api.service
    fi
fi
echo


STATUS=$(sudo systemctl status run.cardanobi-identity-server-admin-sts.service | head -3 | tail -1 | awk '{ print $2 }')
if [[ $STATUS == "active" ]];then
    tput setaf 2; sudo systemctl status run.cardanobi-identity-server-admin-sts.service | head -3

    if [[ $PARAM == "stop" || $PARAM == "stop-admin" ]];then
        echo "Stopping service..."
        sudo systemctl stop run.cardanobi-identity-server-admin-sts.service
    fi
else
    tput setaf 1; sudo systemctl status run.cardanobi-identity-server-admin-sts.service | head -3

    if [[ $PARAM == "start" || $PARAM == "start-admin" ]];then
        echo "Starting service..."
        sudo systemctl start run.cardanobi-identity-server-admin-sts.service
    fi
fi
echo

STATUS=$(sudo systemctl status run.cardanobi-identity-server-admin.service | head -3 | tail -1 | awk '{ print $2 }')
if [[ $STATUS == "active" ]];then
    tput setaf 2; sudo systemctl status run.cardanobi-identity-server-admin.service | head -3

    if [[ $PARAM == "stop" || $PARAM == "stop-admin" ]];then
        echo "Stopping service..."
        sudo systemctl stop run.cardanobi-identity-server-admin.service
    fi
else
    tput setaf 1; sudo systemctl status run.cardanobi-identity-server-admin.service | head -3

    if [[ $PARAM == "start" || $PARAM == "start-admin" ]];then
        echo "Starting service..."
        sudo systemctl start run.cardanobi-identity-server-admin.service
    fi    
fi
echo

# STATUS=$(sudo systemctl status run.cardanobi-identity-server.service | head -3 | tail -1 | awk '{ print $2 }')
# if [[ $STATUS == "active" ]];then
#     tput setaf 2; sudo systemctl status run.cardanobi-identity-server.service | head -3

#     if [[ $PARAM == "stop" ]];then
#         echo "Stopping service..."
#         sudo systemctl stop run.cardanobi-identity-server.service
#     fi
# else
#     tput setaf 1; sudo systemctl status run.cardanobi-identity-server.service | head -3

#     if [[ $PARAM == "start" ]];then
#         echo "Starting service..."
#         sudo systemctl start run.cardanobi-identity-server.service
#     fi
# fi
# echo

tput sgr0
