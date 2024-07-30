#!/bin/bash
# global variables
NOW=`date +"%Y%m%d_%H%M%S"`
SCRIPT_DIR="$(realpath "$(dirname "$0")")"
CARDANOBI_DIR="$HOME/cardanobi"
CONF_PATH="$CARDANOBI_DIR/config"
SCRIPTS_PATH="$CARDANOBI_DIR/scripts"

# echo $SCRIPT_DIR
# echo $CARDANOBI_DIR
# echo $CONF_PATH
# echo $SCRIPTS_PATH

# exit 1

# importing utility functions
# source $SCRIPTS_PATH/utils.sh

if [[ $# -eq 2 && ! $1 == "" && ! $2 == "" ]]; then DOCS_SOURCE_PATH=$1; DOCS_DEST_PATH=$2;
else 
    echo -e "This script requires input parameters:\n\tUsages:"
    echo -e "\t\t$0 {docs_source_path} {docs_destination_path}"
    exit 2
fi

rm -f $DOCS_DEST_PATH/core-domain/*.md
rm -f $DOCS_DEST_PATH/core-domain/*/*.md
rm -f $DOCS_DEST_PATH/bi-domain/*.md
rm -f $DOCS_DEST_PATH/bi-domain/*/*.md

cp -r $DOCS_SOURCE_PATH/core-domain/* $DOCS_DEST_PATH/core-domain
cp -r $DOCS_SOURCE_PATH/bi-domain/* $DOCS_DEST_PATH/bi-domain


echo -e "Done!"