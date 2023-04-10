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
echo '---------------- Deploying CardanoBI nginx log parser  ----------------'
echo

mkdir -p $CARDANOBI_SRV_PATH/nginx
cp  $SCRIPT_DIR/nginx/logparser.js $SCRIPT_DIR/nginx/nginx-log-parser.js $SCRIPT_DIR/nginx/package.json $CARDANOBI_SRV_PATH/nginx
cd $CARDANOBI_SRV_PATH/nginx

cat > $SCRIPT_DIR/nginx/.env << EOF
CARDANOBI_ADMIN_USERNAME="cardano"
CARDANOBI_ADMIN_PASSWORD="cardano"
CARDANOBI_NGINX_LOG_FILE="/var/log/nginx/cardanobi-$CARDANOBI_ENV-api-access.log"
EOF

# adding current user to adm group to be able to watch nginx log files
sudo adduser $USER adm

npm i

NODEJS_PATH=$(which node)
cat > /tmp/run.nginx-log-parser.service << EOF
[Unit]
Description=CardanoBI Nginx Log Parser
Wants=network-online.target
After=multi-user.target

[Service]
User=$USER
Type=simple
WorkingDirectory=$CARDANOBI_SRV_PATH/nginx
Restart=always
RestartSec=5
LimitNOFILE=131072
ExecStart=$NODEJS_PATH nginx-log-parser.js
KillSignal=SIGINT
RestartKillSignal=SIGINT
TimeoutStopSec=2
SuccessExitStatus=143
SyslogIdentifier=run.nginx-log-parser.service

[Install]
WantedBy=multi-user.target
EOF

sudo mv /tmp/run.nginx-log-parser.service /etc/systemd/system
sudo systemctl daemon-reload
sudo systemctl enable run.nginx-log-parser.service


# TODO deploy the stored procedure to create nginx usage views

# modifying cron to schedule update of said views
if [[ $(crontab -l | egrep -v "^(#|$)" | grep -q 'nginx_usage_update'; echo $?) == 1 ]]; then
    echo "No cron entry found for nginx_usage_update. Adding it."

    # Schedule nginx_usage_update(daily) to run every minute
    cat > /tmp/crontab-fragment.txt << EOF
* * * * * psql -d cardanobi_admin -U cardano -W cardano -w -c "call public.nginx_usage_update('daily');"
EOF
    crontab -l | cat - /tmp/crontab-fragment.txt >/tmp/crontab.txt && crontab /tmp/crontab.txt
    rm /tmp/crontab-fragment.txt
    rm /tmp/crontab.txt

        # Schedule nginx_usage_update(hist) to run once a day at 00:01
    cat > /tmp/crontab-fragment.txt << EOF
1 0 * * * psql -d cardanobi_admin -U cardano -W cardano -w -c "call public.nginx_usage_update('hist');"
EOF
    crontab -l | cat - /tmp/crontab-fragment.txt >/tmp/crontab.txt && crontab /tmp/crontab.txt
    rm /tmp/crontab-fragment.txt
    rm /tmp/crontab.txt
else
    echo "Cron entry found for nginx_usage_update. Nothing to do"
fi


echo 
echo '---------------- Getting our firewall ready ----------------'

# Todo automate this for OCI or Azure depending on deployment platform

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