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

echo "NGINX-INIT STARTING..."
echo

echo '---------------- Installing nginx  ----------------'
echo
sudo apt update
sudo apt install nginx

echo
if ! promptyn "Have you modified nginx config to route https traffic to the right port and are you ready to proceed? (y/n)"; then
    echo "Ok bye!"
    exit 1
fi


# Todo here we should copy /config/cardanobi-ENV-web-init into /etc/nginx/sites-available and create matching entry into /etc/nginx/sites-enabled

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