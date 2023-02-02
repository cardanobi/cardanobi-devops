#!/bin/bash
# global variables
NOW=`date +"%Y%m%d_%H%M%S"`
SCRIPT_DIR="$(realpath "$(dirname "$0")")"
CARDANOBI_DIR="$HOME/cardanobi"
CONF_PATH="$CARDANOBI_DIR/config"
SCRIPTS_PATH="$CARDANOBI_DIR/scripts"

DATABASE="cardanobi"
USERNAME="cardano"
PASSWORD="cardano"
DB_CONTEXT="cardanobiContext"

# echo "SCRIPT_DIR: $SCRIPT_DIR"
# echo "CARDANOBI_DIR: $CARDANOBI_DIR"
# echo "SCRIPTS_PATH: $SCRIPTS_PATH"
# echo "CURRENT_DIR: $PWD"
# exit

# importing utility functions
source $SCRIPTS_PATH/utils.sh

if [[ $# -eq 2 && ! $1 == "" && ! $2 == "" ]];then 
    DB_TABLE_NAME=$1; 
    ENTITY_NAME=$2; 
else 
    echo -e "This script requires input parameters:\n\tUsage: $0 {dbTableName} {entityName}"; 
    exit 2; 
fi

echo
if promptyn "Do you want to generate an entity model? (y/n)"; then
    DB_TABLE_NAME=$(prompt_input_default TABLE-NAME $DB_TABLE_NAME)
    DATABASE=$(prompt_input_default DATABASE-NAME $DATABASE)
    USERNAME=$(prompt_input_default DATABASE-USERNAME $USERNAME)
    PASSWORD=$(prompt_input_default DATABASE-PASSWORD $PASSWORD)

    echo
    echo "Entity model generation params:"
    echo "DB TABLE NAME: $DB_TABLE_NAME"
    echo "DATABASE NAME: $DATABASE"
    echo "USERNAME: $USERNAME"
    echo "PASSWORD: $PASSWORD"
    if promptyn "Please confirm you want to proceed? (y/n)"; then
        dotnet ef dbcontext scaffold "Host=localhost;Database=$DATABASE;Username=$USERNAME;Password=$PASSWORD" Npgsql.EntityFrameworkCore.PostgreSQL --output-dir ./tmp/Models --table $DB_TABLE_NAME --data-annotations --use-database-names --force 
    fi
fi

echo
if promptyn "Do you want to generate an entity api controller? (y/n)"; then
    ENTITY_NAME=$(prompt_input_default ENTITY-NAME $ENTITY_NAME)
    ENTITY_CONTROLLER_NAME=$ENTITY_NAME"Controller"
    ENTITY_CONTROLLER_NAME=$(prompt_input_default ENTITY-CONTROLLER-NAME $ENTITY_CONTROLLER_NAME)
    DB_CONTEXT=$(prompt_input_default DB-CONTEXT $DB_CONTEXT)

    echo
    echo "Entity model generation params:"
    echo "ENTITY CONTROLLER NAME: $ENTITY_CONTROLLER_NAME"
    echo "ENTITY NAME: $ENTITY_NAME"
    echo "DB CONTEXT: $DB_CONTEXT"
    if promptyn "Please confirm you want to proceed? (y/n)"; then
        dotnet aspnet-codegenerator controller -name $ENTITY_CONTROLLER_NAME -async -api -m $ENTITY_NAME -dc $DB_CONTEXT -outDir ./tmp/Controllers
    fi
fi