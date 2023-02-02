#!/bin/bash
# global variables
NOW=`date +"%Y%m%d_%H%M%S"`
SCRIPT_DIR="$(realpath "$(dirname "$0")")"
CARDANOBI_DIR="$(realpath "$(dirname "$SCRIPT_DIR")")"
CONF_PATH="$CARDANOBI_DIR/config"
SCRIPTS_PATH="$CARDANOBI_DIR/scripts"

# importing utility functions
source $SCRIPTS_PATH/utils.sh

echo "NGINX-INIT STARTING..."
echo

echo '---------------- Installing nginx  ----------------'
echo
sudo apt update
sudo apt install nginx

if ! promptyn "Have you modified nginx config to route https traffic to the right port and are you ready to proceed? (y/n)"; then
    echo "Ok bye!"
    exit 1
fi

sudo nginx -t
sudo service nginx reload

sudo apt install certbot python3-certbot-nginx

echo '---------------- Installing certbot  ----------------'
echo
DOMAIN_TO_SECURE="preprod.cardanobi.io"
DOMAIN_TO_SECURE=$(prompt_input_default DOMAIN_TO_SECURE $DOMAIN_TO_SECURE)

echo
echo "Details of your certbot certification:"
echo "DOMAIN_TO_SECURE: $DOMAIN_TO_SECURE"
if ! promptyn "Please confirm you want to proceed? (y/n)"; then
    echo "Ok bye!"
    exit 1
fi

sudo certbot --nginx -d $DOMAIN_TO_SECURE

echo
echo "Checking certbot auto renewal timer:"
sudo systemctl status certbot.timer

echo "NGINX-INIT COMPLETE."