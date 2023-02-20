#!/bin/bash
# global variables
NOW=`date +"%Y%m%d_%H%M%S"`
SCRIPT_DIR="$(realpath "$(dirname "$0")")"
BASE_DIR="$(realpath "$(dirname "$SCRIPT_DIR")")"
ROOT_DIR="$(realpath "$(dirname "$BASE_DIR")")"
CONF_PATH="$BASE_DIR/config"

echo "SCRIPT_DIR: $SCRIPT_DIR"
echo "BASE_DIR: $BASE_DIR"
echo "ROOT_DIR: $ROOT_DIR"
echo "CONF_PATH: $CONF_PATH"
echo

# importing utility functions
source $BASE_DIR/utils.sh
DATABASE="cardanobi"
USERNAME="cardano"
PASSWORD="cardano"
DB_CONTEXT="cardanobiContext"
WORKING_DIR=$ROOT_DIR/cardanobi-backend-api/src

if [[ $# -eq 2 && ! $1 == "" && ! $2 == "" ]];then 
    DB_TABLE_NAME=$1; 
    ENTITY_NAME=$2; 
else 
    echo -e "This script requires input parameters:\n\tUsage: $0 {dbTableName} {entityName}"; 
    exit 2; 
fi

mkdir -p /tmp/cardanobi/Controllers
mkdir -p /tmp/cardanobi/Models

echo
if promptyn "Do you want to generate an entity model? (y/n)"; then
    DB_TABLE_NAME=$(prompt_input_default TABLE-NAME $DB_TABLE_NAME)
    DATABASE=$(prompt_input_default DATABASE-NAME $DATABASE)
    USERNAME=$(prompt_input_default DATABASE-USERNAME $USERNAME)
    PASSWORD=$(prompt_input_default DATABASE-PASSWORD $PASSWORD)
    WORKING_DIR=$(prompt_input_default WORKING_DIR $WORKING_DIR)

    echo
    echo "Entity model generation params:"
    echo "DB TABLE NAME: $DB_TABLE_NAME"
    echo "DATABASE NAME: $DATABASE"
    echo "USERNAME: $USERNAME"
    echo "PASSWORD: $PASSWORD"
    if promptyn "Please confirm you want to proceed? (y/n)"; then
        cd $WORKING_DIR
        dotnet ef dbcontext scaffold "Host=localhost;Database=$DATABASE;Username=$USERNAME;Password=$PASSWORD" Npgsql.EntityFrameworkCore.PostgreSQL --output-dir /tmp/cardanobi/Models --table $DB_TABLE_NAME --data-annotations --use-database-names --force 
    fi
fi

echo
if promptyn "Do you want to generate an entity api controller? (y/n)"; then
    ENTITY_NAME=$(prompt_input_default ENTITY-NAME $ENTITY_NAME)
    ENTITY_CONTROLLER_NAME=$ENTITY_NAME"Controller"
    ENTITY_CONTROLLER_NAME=$(prompt_input_default ENTITY-CONTROLLER-NAME $ENTITY_CONTROLLER_NAME)
    DB_CONTEXT=$(prompt_input_default DB-CONTEXT $DB_CONTEXT)
    WORKING_DIR=$(prompt_input_default WORKING_DIR $WORKING_DIR)

    echo
    echo "Entity model generation params:"
    echo "ENTITY CONTROLLER NAME: $ENTITY_CONTROLLER_NAME"
    echo "ENTITY NAME: $ENTITY_NAME"
    echo "DB CONTEXT: $DB_CONTEXT"
    if promptyn "Please confirm you want to proceed? (y/n)"; then
        cd $WORKING_DIR
        dotnet aspnet-codegenerator controller -name $ENTITY_CONTROLLER_NAME -async -api -m $ENTITY_NAME -dc $DB_CONTEXT -outDir /tmp/cardanobi/Controllers
    fi
fi