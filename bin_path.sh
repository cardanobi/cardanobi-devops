#!/bin/bash

if [[ $# -eq 2 && ! $1 == "" && ! $2 == "" ]]; then 
    BIN_NAME=$1
    BIN_PATH=$2
else 
    echo -e "This script requires input parameters:\n\tUsage: $0 {binaryName} {cardanoNodePath}"
    exit 2
fi

echo $BIN_NAME
echo $BIN_PATH

find $BIN_PATH -name $BIN_NAME -executable -type f
# echo "$(jq -r '."install-plan"[] | select(."component-name" == "exe:'$BIN_NAME'") | ."bin-file"' $BIN_PATH/dist-newstyle/cache/plan.json | head -n 1)"
# echo "$(jq -r '."install-plan"[] | select(."component-name" == "exe:'$BIN_NAME'") | ."bin-file"' $CARDANO_NODE_PATH/dist-newstyle/cache/plan.json | head -n 1)"