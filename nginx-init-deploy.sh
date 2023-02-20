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

echo "NGINX-DEPLOY STARTING..."
echo


echo '---------------- Deploying CardanoBI nginx config  ----------------'
echo
CARDANOBI_ENV="preprod"
CARDANOBI_ENV=$(prompt_input_default CARDANOBI_ENV $CARDANOBI_ENV)
CARDANOBI_SRV_PATH=$BASE_DIR
CARDANOBI_SRV_PATH=$(prompt_input_default CARDANOBI_SRV_PATH $CARDANOBI_SRV_PATH)

echo
echo "Details of your CardanoBI nginx config deployment:"
echo "CARDANOBI_ENV: $CARDANOBI_ENV"
if ! promptyn "Please confirm you want to proceed? (y/n)"; then
    echo "Ok bye!"
    exit 1
fi

sudo cp $CONF_PATH/nginx/$CARDANOBI_ENV/cardanobi-$CARDANOBI_ENV-api /etc/nginx/sites-available
sudo cp $CONF_PATH/nginx/$CARDANOBI_ENV/cardanobi-$CARDANOBI_ENV-default /etc/nginx/sites-available
sudo cp $CONF_PATH/nginx/$CARDANOBI_ENV/cardanobi-$CARDANOBI_ENV-idserver /etc/nginx/sites-available
sudo cp $CONF_PATH/nginx/$CARDANOBI_ENV/cardanobi-$CARDANOBI_ENV-idserver-admin /etc/nginx/sites-available
sudo cp $CONF_PATH/nginx/$CARDANOBI_ENV/cardanobi-$CARDANOBI_ENV-idserver-adminapi /etc/nginx/sites-available
sudo cp $CONF_PATH/nginx/$CARDANOBI_ENV/cardanobi-$CARDANOBI_ENV-idserver-adminui /etc/nginx/sites-available
sudo cp $CONF_PATH/nginx/$CARDANOBI_ENV/cardanobi-$CARDANOBI_ENV-web /etc/nginx/sites-available

cd /etc/nginx/sites-enabled

sudo ln -s /etc/nginx/sites-available/cardanobi-$CARDANOBI_ENV-api cardanobi-$CARDANOBI_ENV-api
sudo ln -s /etc/nginx/sites-available/cardanobi-$CARDANOBI_ENV-default cardanobi-$CARDANOBI_ENV-default
sudo ln -s /etc/nginx/sites-available/cardanobi-$CARDANOBI_ENV-idserver cardanobi-$CARDANOBI_ENV-idserver
sudo ln -s /etc/nginx/sites-available/cardanobi-$CARDANOBI_ENV-idserver-admin cardanobi-$CARDANOBI_ENV-idserver-admin
sudo ln -s /etc/nginx/sites-available/cardanobi-$CARDANOBI_ENV-idserver-adminapi cardanobi-$CARDANOBI_ENV-idserver-adminap
sudo ln -s /etc/nginx/sites-available/cardanobi-$CARDANOBI_ENV-idserver-adminui cardanobi-$CARDANOBI_ENV-idserver-adminui
# sudo ln -s /etc/nginx/sites-available/cardanobi-$CARDANOBI_ENV-web cardanobi-$CARDANOBI_ENV-web

sudo cp $CONF_PATH/nginx/$CARDANOBI_ENV/*.html /usr/share/nginx/html

mkdir -p $CARDANOBI_SRV_PATH/config/nginx
sudo cp $CONF_PATH/nginx/$CARDANOBI_ENV/*.map $CARDANOBI_SRV_PATH/config/nginx

sudo nginx -t
sudo service nginx reload

echo 
echo '---------------- Getting our firewall ready ----------------'

# Todo automate this of OCI or Azure depending on deployment platform

sudo firewall-cmd --zone=public --add-port=4000/tcp --permanent
sudo firewall-cmd --zone=public --add-port=5000/tcp --permanent
sudo firewall-cmd --zone=public --add-port=44010/tcp --permanent
sudo firewall-cmd --zone=public --add-port=44002/tcp --permanent
sudo firewall-cmd --zone=public --add-port=44003/tcp --permanent
sudo firewall-cmd --reload
sudo firewall-cmd --list-all

echo
echo "Ports have been opened."
if ! promptyn "Have you add Ingress Rules in your OCI VCN for the same? (y/n)"; then
    echo "Ok bye!"
    exit 1
fi

echo "NGINX-DEPLOY COMPLETE."