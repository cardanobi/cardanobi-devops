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

CARDANOBI_ENV="preprod"
echo "Which environment are you working on?"
CARDANOBI_ENV=$(prompt_input_default CARDANOBI_ENV $CARDANOBI_ENV)


echo "Which action do you want to run?"
echo -e "\t 1 - Backout all env nginx config and reinstate the default setup to generate a new cert?"
echo -e "\t 2 - Reinstate all nginx setup for the current env?"

ACTION_NO=1
ACTION_NO=$(prompt_input_default ACTION_NO $ACTION_NO)

if [[ $ACTION_NO -eq 1 ]]; then
    echo
    if ! promptyn "About to regen the current env certificate, ok to proceed? (y/n)"; then
        echo "Ok bye!"
        exit 1
    fi
    echo "Removing from sites-enabled..."
    echo

    sudo rm -f /etc/nginx/sites-enabled/cardanobi-$CARDANOBI_ENV-api
    sudo rm -f /etc/nginx/sites-enabled/cardanobi-$CARDANOBI_ENV-default
    sudo rm -f /etc/nginx/sites-enabled/cardanobi-$CARDANOBI_ENV-idserver
    sudo rm -f /etc/nginx/sites-enabled/cardanobi-$CARDANOBI_ENV-idserver-admin
    sudo rm -f /etc/nginx/sites-enabled/cardanobi-$CARDANOBI_ENV-idserver-adminapi
    sudo rm -f /etc/nginx/sites-enabled/cardanobi-$CARDANOBI_ENV-idserver-adminui
    sudo rm -f /etc/nginx/sites-enabled/cardanobi-$CARDANOBI_ENV-portal
    sudo rm -f /etc/nginx/sites-enabled/cardanobi-$CARDANOBI_ENV-bff

    echo "Enabling web-init-portal for certbot setup..."
    echo

    sudo cp $CONF_PATH/nginx/$CARDANOBI_ENV/cardanobi-preprod-web-init-portal /etc/nginx/sites-available
    cd /etc/nginx/sites-enabled
    sudo ln -s /etc/nginx/sites-available/cardanobi-$CARDANOBI_ENV-web-init-portal cardanobi-$CARDANOBI_ENV-web-init-portal

    echo "Reloading nginx..."
    echo

    sudo nginx -t
    sudo service nginx reload

    echo
    if ! promptyn "Please check all is ok and confirm if you are ready to proceed? (y/n)"; then
        echo "Ok bye!"
        exit 1
    fi

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
elif [[ $ACTION_NO -eq 2 ]]; then
    echo
    if ! promptyn "About to reinstate all env nginx config, ok to proceed? (y/n)"; then
        echo "Ok bye!"
        exit 1
    fi

    cd /etc/nginx/sites-enabled
    sudo ln -s /etc/nginx/sites-available/cardanobi-$CARDANOBI_ENV-api cardanobi-$CARDANOBI_ENV-api
    sudo ln -s /etc/nginx/sites-available/cardanobi-$CARDANOBI_ENV-idserver-admin cardanobi-$CARDANOBI_ENV-idserver-admin
    sudo ln -s /etc/nginx/sites-available/cardanobi-$CARDANOBI_ENV-idserver-adminapi cardanobi-$CARDANOBI_ENV-idserver-adminapi
    sudo ln -s /etc/nginx/sites-available/cardanobi-$CARDANOBI_ENV-idserver-adminui cardanobi-$CARDANOBI_ENV-idserver-adminui
    sudo ln -s /etc/nginx/sites-available/cardanobi-$CARDANOBI_ENV-portal cardanobi-$CARDANOBI_ENV-portal
    sudo ln -s /etc/nginx/sites-available/cardanobi-$CARDANOBI_ENV-bff cardanobi-$CARDANOBI_ENV-bff

    sudo rm -f /etc/nginx/sites-enabled/cardanobi-$CARDANOBI_ENV-web-init-portal

    sudo nginx -t
    sudo service nginx reload
    echo
    echo "All done."
else
    echo "Unknown Action, bye for now!"
    exit 1
fi

