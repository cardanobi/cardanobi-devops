#!/bin/bash

# prompt yes no
promptyn () {
    while true; do
        read -p "$1 " yn
        case $yn in
            [Yy]* ) return 0;;
            [Nn]* ) return 1;;
            * ) echo "Please answer yes or no.";;
        esac
    done
}

# prompt for a value with proposed default value
prompt_input_default() {
 read -p "$1? (default: $2)"": " val
 val="${val:=$2}"
 echo $val
}

# check no internet connection
check_air_gap() {
    if ping -q -c 1 -W 1 google.com >/dev/null; then
        ret=0
    else
        ret=1
    fi
    echo $ret
 }

# script state utils
save_state () {
  typeset -p "$@" >"$STATE_FILE"
}

print_state () {
  echo "state:" "$@"
}

# spot topology utils
get_topo () {
    TOPO_FILE=$1
    MY_IP=$(hostname -I | xargs)
    NODE_TYPE="unknown"
    BP_IP=""
    RELAY_IPS=()
    RELAY_NAMES=()
    RELAY_IPS_PUB=()
    ERROR="none"
    # echo "MY_IP: ${MY_IP}"

    # if [[ -z "$MY_IP" ]]; then
    #     echo "air-gap!"
    # else
    #     echo "online"
    # fi

    if [[ -f "$TOPO_FILE" ]]; then
        if [[ -z "$MY_IP" ]]; then
            NODE_TYPE="airgap"
        fi
        
        while IFS= read -r TOPO; do
            # echo $TOPO
            if [[ ! -z $TOPO && ! $TOPO == \#* ]]; then
                TOPO_IP=$(awk '{ print $1 }' <<< "${TOPO}")
                TOPO_NAME=$(awk '{ print $2 }' <<< "${TOPO}")
                TOPO_IP_PUB=$(awk '{ print $3 }' <<< "${TOPO}")
                #echo "TOPO_IP: ${TOPO_IP}"
                #echo "TOPO_NAME: ${TOPO_NAME}"
                if [[ $TOPO_NAME == "bp" ]]; then
                    BP_IP=$TOPO_IP
                fi

                if [[ $TOPO_IP == $MY_IP ]]; then
                    if [[ "$TOPO_NAME" == *"bp"* ]]; then
                        NODE_TYPE="bp"
                    elif [[ "$TOPO_NAME" == *"relay"* ]]; then
                        NODE_TYPE="relay"
                    fi
                fi
                if [[ "$TOPO_NAME" == *"relay"* ]]; then
                    RELAY_IPS+=($TOPO_IP)
                    RELAY_NAMES+=($TOPO_NAME)
                    RELAY_IPS_PUB+=($TOPO_IP_PUB)
                fi
            fi
        done <$TOPO_FILE

        # echo "NODE_TYPE: $NODE_TYPE"
        # echo "RELAY_IPS: ${RELAY_IPS[@]}"
        # echo "RELAY_NAMES: ${RELAY_NAMES[@]}"
    else 
        ERROR="$TOPO_FILE does not exist. Please create it as per instructions and run this script again."
    fi

    echo "$ERROR $NODE_TYPE $BP_IP ${RELAY_IPS[@]} ${RELAY_NAMES[@]} ${RELAY_IPS_PUB[@]}"
}

