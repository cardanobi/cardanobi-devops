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

# relay node setup process
CARDANO_NODE_PATH="\$HOME/node.relay"
CARDANO_NODE_PATH=$(prompt_input_default CARDANO_NODE_PATH $CARDANO_NODE_PATH)

SPOT_DIR="\$HOME"
SPOT_DIR=$(prompt_input_default SPOT_DIR $SPOT_DIR)

SPOT_ENV=mainnet
SPOT_ENV=$(prompt_input_default SPOT_ENV $SPOT_ENV)

echo
echo "Details of your cardano relay node install:"
echo "CARDANO_NODE_PATH: $CARDANO_NODE_PATH"
echo "SPOT_DIR: $SPOT_DIR"
echo "SPOT_ENV: $SPOT_ENV"
if ! promptyn "Please confirm you want to proceed? (y/n)"; then
    echo "Ok bye!"
    exit 1
fi

# spot setup
eval cd $SPOT_DIR
git clone https://github.com/adacapital/spot.git

# setting up important environment variables
echo "\$CARDANO_NODE_SOCKET_PATH Before: $CARDANO_NODE_SOCKET_PATH"
if [[ ! ":$CARDANO_NODE_SOCKET_PATH:" == *":$CARDANO_NODE_PATH/socket:"* ]]; then
    echo "$CARDANO_NODE_PATH/socket not found in \$CARDANO_NODE_SOCKET_PATH"
    echo "Tweaking your .bashrc"
    echo $"if [[ ! ":'$CARDANO_NODE_SOCKET_PATH':" == *":$CARDANO_NODE_PATH/socket:"* ]]; then
    export CARDANO_NODE_SOCKET_PATH=$CARDANO_NODE_PATH/socket/node.socket
fi" >> ~/.bashrc
    eval "$(cat ~/.bashrc | tail -n +10)"
else
    echo "$CARDANO_NODE_PATH/socket found in \$CARDANO_NODE_SOCKET_PATH, nothing to change here."
fi
echo "\$CARDANO_NODE_SOCKET_PATH After: $CARDANO_NODE_SOCKET_PATH"

echo "\$CARDANO_CARDANO_NODE_PATH Before: $CARDANO_CARDANO_NODE_PATH"
if [[ ! ":$CARDANO_CARDANO_NODE_PATH:" == *":$CARDANO_NODE_PATH:"* ]]; then
    echo "$CARDANO_NODE_PATH not found in \$CARDANO_CARDANO_NODE_PATH"
    echo "Tweaking your .bashrc"
    echo $"if [[ ! ":'$CARDANO_CARDANO_NODE_PATH':" == *":$CARDANO_NODE_PATH:"* ]]; then
    export CARDANO_CARDANO_NODE_PATH=$CARDANO_NODE_PATH
fi" >> ~/.bashrc
    eval "$(cat ~/.bashrc | tail -n +10)"
else
    echo "$CARDANO_NODE_PATH found in \$CARDANO_CARDANO_NODE_PATH, nothing to change here."
fi
echo "\$CARDANO_CARDANO_NODE_PATH After: $CARDANO_CARDANO_NODE_PATH"

if [[ ! ":$SPOT_PATH:" == *":$SPOT_DIR/$SPOT_ENV:"* ]]; then
    echo "$SPOT_DIR/$SPOT_ENV not found in \$SPOT_PATH"
    echo "Tweaking your .bashrc"
    echo $"if [[ ! ":'$SPOT_PATH':" == *":$SPOT_DIR/$SPOT_ENV:"* ]]; then
    export SPOT_PATH=$SPOT_DIR/$SPOT_ENV
fi" >> ~/.bashrc
    eval "$(cat ~/.bashrc | tail -n +10)"
else
    echo "$SPOT_DIR/$SPOT_ENV found in \$SPOT_PATH, nothing to change here."
fi
echo "\$SPOT_PATH After: $SPOT_PATH"

echo
echo "Getting node.relay folder ready..."
eval mkdir -p $CARDANO_NODE_PATH/config
eval mkdir -p $CARDANO_NODE_PATH/db
eval mkdir -p $CARDANO_NODE_PATH/socket

eval cd $CARDANO_NODE_PATH
FULL_CARDANO_NODE_PATH=$(pwd)
eval cd $CARDANO_NODE_PATH/config
# wget -O config.json https://raw.githubusercontent.com/input-output-hk/cardano-world/master/docs/environments/$SPOT_ENV/config.json
wget -O bgenesis.json https://raw.githubusercontent.com/input-output-hk/cardano-world/master/docs/environments/$SPOT_ENV/byron-genesis.json
wget -O sgenesis.json https://raw.githubusercontent.com/input-output-hk/cardano-world/master/docs/environments/$SPOT_ENV/shelley-genesis.json
wget -O agenesis.json https://raw.githubusercontent.com/input-output-hk/cardano-world/master/docs/environments/$SPOT_ENV/alonzo-genesis.json
# wget -O topology.json https://raw.githubusercontent.com/input-output-hk/cardano-world/master/docs/environments/$SPOT_ENV/topology.json
wget -O db-sync-config.json https://raw.githubusercontent.com/input-output-hk/cardano-world/master/docs/environments/$SPOT_ENV/db-sync-config.json
wget -O submit-api-config.json https://raw.githubusercontent.com/input-output-hk/cardano-world/master/docs/environments/$SPOT_ENV/submit-api-config.json

cp $SCRIPT_DIR/config/node-relay-config.json ./config.json
sed -i "s|\/home\/cardano\/node.relay|${FULL_CARDANO_NODE_PATH}|g" config.json

echo
echo "Now tar, scp and untar to this machine a copy of a fully synched node.relay from the same environment."
echo
if ! promptyn "Please confirm you have done as requested and that you are ready to continue? (y/n)"; then
    echo "Ok bye!"
    exit 1
fi

echo
echo '---------------- Getting our node systemd services ready ----------------'

cat > $FULL_CARDANO_NODE_PATH/run.relay.service << EOF
[Unit]
Description=Cardano Relay Node Run Script
Wants=network-online.target
After=multi-user.target

[Service]
User=$USER
Type=simple
WorkingDirectory=$FULL_CARDANO_NODE_PATH
Restart=always
RestartSec=5
LimitNOFILE=131072
ExecStart=/bin/bash -c '$FULL_CARDANO_NODE_PATH/run.relay.sh'
KillSignal=SIGINT
RestartKillSignal=SIGINT
TimeoutStopSec=2
SuccessExitStatus=143
SyslogIdentifier=run.relay

[Install]
WantedBy=multi-user.target
EOF

sudo mv $FULL_CARDANO_NODE_PATH/run.relay.service /etc/systemd/system/run.relay.service
sudo systemctl daemon-reload
sudo systemctl enable run.relay

cp $SCRIPT_DIR/config/run.relay.sh .
cp $SCRIPT_DIR/config/topology_updater.sh .

echo
echo '---------------- Preparing devops files ----------------'

sudo apt install bc tcptraceroute curl -y

# installing gLiveView tool for relay node
eval cd $CARDANO_NODE_PATH
curl -s -o gLiveView.sh https://raw.githubusercontent.com/cardano-community/guild-operators/master/scripts/cnode-helper-scripts/gLiveView.sh
curl -s -o env https://raw.githubusercontent.com/cardano-community/guild-operators/master/scripts/cnode-helper-scripts/env
chmod 755 gLiveView.sh

sed -i env \
    -e "s/\#CNODE_HOME=\"\/opt\/cardano\/cnode\"/CNODE_HOME=\"\$\{CARDANO_NODE_PATH\}\"/g" \
    -e "s/CNODE_PORT=6000/CNODE_PORT=3001/g" \
    -e "s/\#CONFIG=\"\${CNODE_HOME}\/files\/config.json\"/CONFIG=\"\${CARDANO_NODE_PATH}\/config\/config.json\"/g" \
    -e "s/\#SOCKET=\"\${CNODE_HOME}\/sockets\/node0.socket\"/SOCKET=\"\${CARDANO_NODE_PATH}\/socket\/node.socket\"/g" \
    -e "s/\#TOPOLOGY=\"\${CNODE_HOME}\/files\/topology.json\"/TOPOLOGY=\"\${CARDANO_NODE_PATH}\/config\/topology.json\"/g" \
    -e "s/\#LOG_DIR=\"\${CNODE_HOME}\/logs\"/LOG_DIR=\"\${CARDANO_NODE_PATH}\/logs\"/g" \
    -e "s/\#DB_DIR=\"\${CNODE_HOME}\/db\"/DB_DIR=\"\${CARDANO_NODE_PATH}\/db\"/g"

echo 
echo '---------------- Getting our firewall ready ----------------'

sudo apt-get install firewalld 
sudo systemctl enable firewalld
sudo systemctl start firewalld 

sudo firewall-cmd --zone=public --add-port=3001/tcp --permanent
sudo firewall-cmd --reload
sudo firewall-cmd --list-all