# global variables
NOW=`date +"%Y%m%d_%H%M%S"`
SCRIPT_DIR="$(realpath "$(dirname "$0")")"
BASE_DIR="$(realpath "$(dirname "$SCRIPT_DIR")")"
CONF_PATH="$BASE_DIR/config"

echo "SCRIPT_DIR: $SCRIPT_DIR"
echo "BASE_DIR: $BASE_DIR"
echo "CONF_PATH: $CONF_PATH"
echo

# importing utility functions
source $BASE_DIR/utils.sh

# from source setup process start - get user input
INSTALL_PATH=$HOME
INSTALL_PATH=$(prompt_input_default INSTALL_PATH $INSTALL_PATH)

CARDANOBI_ENV=preprod
CARDANOBI_ENV=$(prompt_input_default CARDANOBI_ENV $CARDANOBI_ENV)

echo
echo "Details of your CardanoBI Identity Server install from source:"
echo "INSTALL_PATH: $INSTALL_PATH"
echo "CARDANOBI_ENV: $CARDANOBI_ENV"
if ! promptyn "Please confirm you want to proceed? (y/n)"; then
    echo "Ok bye!"
    exit 1
fi

echo
cd INSTALL_PATH

# Identity Server Admin
git clone https://github.com/cardanobi/Duende.IdentityServer.Admin.git

# TODO automate:
# For IdentityServer.Admin, IdentityServer.Admin.API, IdentityServer.STS.Identity
#   appsettings.json: sed for PSQL_USER_ID, PSQL_USER_PASSWORD, PSQL_DB_NAME, DOMAIN_NAME
#   generate appsettings.Development.json & appsettings.Producton.json (pay attention to added Kestrel element)
# Then dotnet build for each package in [IdentityServer.Admin, IdentityServer.Admin.API, IdentityServer.STS.Identity]
# Then run dotnet run /seed in IdentityServer.Admin to create cardanobi_admin

echo 

# Identity Server 
git clone https://github.com/cardanobi/cardanobi-backend-identity.git

# TODO automate:
#   appsettings.json: sed for PSQL_USER_ID, PSQL_USER_PASSWORD, PSQL_DB_NAME
#   generate appsettings.Development.json & appsettings.Producton.json (pay attention to added Kestrel element)
echo
echo "Installation completed!"