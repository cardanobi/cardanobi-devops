#!/bin/bash

echo "Checking running status for CardanoBI key services:"
echo

STATUS=$(sudo systemctl status run.cardano-db-sync.service | head -3 | tail -1 | awk '{ print $2 }')
if [[ $STATUS == "active" ]]; then
    tput setaf 2; sudo systemctl status run.cardano-db-sync.service | head -3
else
    tput setaf 1; sudo systemctl status run.cardano-db-sync.service | head -3
fi
echo

STATUS=$(sudo systemctl status run.cardanobi-api-core.service | head -3 | tail -1 | awk '{ print $2 }')
if [[ $STATUS == "active" ]]; then
    tput setaf 2; sudo systemctl status run.cardanobi-api-core.service | head -3
else
    tput setaf 1; sudo systemctl status run.cardanobi-api-core.service | head -3
fi
echo

STATUS=$(sudo systemctl status run.cardanobi-identity-server-admin-api.service | head -3 | tail -1 | awk '{ print $2 }')
if [[ $STATUS == "active" ]]; then
    tput setaf 2; sudo systemctl status run.cardanobi-identity-server-admin-api.service | head -3
else
    tput setaf 1; sudo systemctl status run.cardanobi-identity-server-admin-api.service | head -3
fi
echo


STATUS=$(sudo systemctl status run.cardanobi-identity-server-admin-sts.service | head -3 | tail -1 | awk '{ print $2 }')
if [[ $STATUS == "active" ]]; then
    tput setaf 2; sudo systemctl status run.cardanobi-identity-server-admin-sts.service | head -3
else
    tput setaf 1; sudo systemctl status run.cardanobi-identity-server-admin-sts.service | head -3
fi
echo

STATUS=$(sudo systemctl status run.cardanobi-identity-server-admin.service | head -3 | tail -1 | awk '{ print $2 }')
if [[ $STATUS == "active" ]]; then
    tput setaf 2; sudo systemctl status run.cardanobi-identity-server-admin.service | head -3
else
    tput setaf 1; sudo systemctl status run.cardanobi-identity-server-admin.service | head -3
fi
echo

STATUS=$(sudo systemctl status run.cardanobi-identity-server.service | head -3 | tail -1 | awk '{ print $2 }')
if [[ $STATUS == "active" ]]; then
    tput setaf 2; sudo systemctl status run.cardanobi-identity-server.service | head -3
else
    tput setaf 1; sudo systemctl status run.cardanobi-identity-server.service | head -3
fi
echo

tput sgr0
