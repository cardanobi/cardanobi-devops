#!/bin/bash
# loading important environment variables by forcing .bashrc to be reloaded
# useful as this script will be run as a systemd service for which no env variable are preloaded
eval "$(cat ~/.bashrc | tail -n +10)"

cardano-node +RTS -N2 --disable-delayed-os-memory-return -I0.3 -Iw600 -A16m -F1.5 -H2500M -T -S -RTS run \
  --topology $CARDANO_NODE_PATH/config/topology.json \
  --database-path $CARDANO_NODE_PATH/db/ \
  --socket-path $CARDANO_NODE_PATH/socket/node.socket \
  --host-addr 0.0.0.0 \
  --port 3001 \
  --config $CARDANO_NODE_PATH/config/config.json
