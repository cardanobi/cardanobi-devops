#!/bin/bash

if [[ $# -eq 1 && ! $1 == "" ]];then 
    BIN_NAME=$1; 
    BIN_PATH=~/$BIN_NAME; 
elif [[ $# -eq 2 && ! $1 == "" && ! $2 == "" ]];then 
    BIN_NAME=$1; 
    BIN_PATH=$2; 
else 
    echo -e "This script requires input parameters:\n\tUsage: $0 {binaryName} {binaryPath:optional}"; 
    exit 2; 
fi

# echo "$(jq -r '."install-plan"[] | select(."component-name" == "exe:'$BIN_NAME'") | ."bin-file"' $BIN_PATH/dist-newstyle/cache/plan.json | head -n 1)"
find $BIN_PATH -name $BIN_NAME -executable -type f