#!/bin/bash
#
tput clear
trap ctrl_c INT

function ctrl_c() {
        echo "**You pressed Ctrl+C...Exiting"
        exit 0;
}

# Capture output to file
capture_output() {
    exec > >(tee -a "$output_file") 2>&1
}

# Check commands
check_command() {
    command -v "$1" >/dev/null 2>&1 || { echo >&2 "Error : $1 is not installed. Please install it.";
    exit 1; }
}

check_command tput
check_command date
check_command grep
check_command awk
check_command jq

# Check if cardano-node is installed
if ! cardano-node version &>/dev/null; then
    echo "Error : cardano-node is not installed. Please install Cardano."
    exit 1
fi

echo -e "#########################################################################"
echo -e "#########################################################################"
echo "   ____              _                        _             _ _ _      ";
echo "  / ___|__ _ _ __ __| | __ _ _ __   ___      / \  _   _  __| (_) |_    ";
echo " | |   / _\` | '__/ _\` |/ _\` | '_ \ / _ \    / _ \| | | |/ _\` | | __|   ";
echo " | |__| (_| | | | (_| | (_| | | | | (_) |  / ___ \ |_| | (_| | | |_    ";
echo "  \____\__,_|_|  \__,_|\__,_|_| |_|\___/  /_/   \_\__,_|\__,_|_|\__|   ";
echo "  / _| ___  _ __    ___ ___ (_)_ __   ___ __ _ ___| |__   _____      __";
echo " | |_ / _ \| '__|  / __/ _ \| | '_ \ / __/ _\` / __| '_ \ / _ \ \ /\ / /";
echo " |  _| (_) | |    | (_| (_) | | | | | (_| (_| \__ \ | | |  __/\ V  V / ";
echo " |_|  \___/|_|     \___\___/|_|_| |_|\___\__,_|___/_| |_|\___| \_/\_/  ";
echo "                                                                       ";
echo
echo "v6.0.0" 
echo "by FRADA stake pool"
echo
echo "#########################################################################"
echo "Audit script for your cardano node installation"
echo "#########################################################################"
echo
echo -e "\e[0;36mThis script will parse and analyze info about your Cardano Node."
echo -e "\e[0;36mIt can help you harden your security, and check if your node configuration"
echo -e "\e[0;36mis correct. It is designed for a Coincashew installation, but can be used"
echo -e "\e[0;36mon other setups, for security checks only.\e[0m"
echo
echo "#########################################################################"
echo
echo "Do you want to export the audit results to a file?"
VALID_EXPORT_ANSWER=false
while [[ $VALID_EXPORT_ANSWER == false ]]; do
    read -r -p " (YES/NO) : " EXPORT_ANSWER
    EXPORT_ANSWER_LOWER=$(echo "$EXPORT_ANSWER" | tr '[:upper:]' '[:lower:]')
    if [[ "$EXPORT_ANSWER_LOWER" == "yes" ]]; then
        timestamp=$(date +"%Y%m%d_%H%M%S")
        output_file="cardano_audit_${timestamp}.txt"
        echo "Audit results will be exported to : $output_file"
        VALID_EXPORT_ANSWER=true
    elif [[ "$EXPORT_ANSWER_LOWER" == "no" ]]; then
        VALID_EXPORT_ANSWER=true
    else
        echo -e " \e[1;31mInvalid answer. Please enter YES or NO\e[0m"
    fi
done
echo
echo "Is it a Coincashew Cardano node setup ?"
VALID_ANSWER=false
while [[ $VALID_ANSWER == false ]]; do
    read -r -p " (YES/NO) : " COINCASHEW_ANSWER
    COINCASHEW_ANSWER_LOWER=$(echo "$COINCASHEW_ANSWER" | tr '[:upper:]' '[:lower:]')
        if [[ "$COINCASHEW_ANSWER_LOWER" == "yes" ]]; then
            VALID_ANSWER=true
        elif [[ "$COINCASHEW_ANSWER_LOWER" == "no" ]]; then
            VALID_ANSWER=true
        else
            echo -e " \e[1;31mInvalid answer. Please enter YES or NO\e[0m"
        fi
done
echo
echo "Script Starts in 3 seconds"
sleep 1
echo "2"
sleep 1
echo "1"
sleep 1
if [[ "$EXPORT_ANSWER_LOWER" == "yes" ]]; then
    capture_output
    {
        echo "--------------------------------------------------------------"    
        echo "Cardano Audit Script started on : $(date)"
        echo "--------------------------------------------------------------"
    } >> "$output_file"
fi
START=$(date +%s)
if [[ "$COINCASHEW_ANSWER_LOWER" == "yes" ]]; then
    echo
    echo -e "\e[0;33m/////// ENVIRONNEMENT VARIABLES CHECK /////// \e[0m"
    sleep 1
    echo
    if [ -z ${NODE_HOME+x} ]; then
        echo
        echo -e " [\e[1;31mKO\e[0m] NODE_HOME env variable not set. !! Script won't work correctly !!"
        echo
    else
        echo -e " [\e[1;32mOK\e[0m] Cardano Node Directory :        "$NODE_HOME
    fi
    if [ -z ${CARDANO_NODE_SOCKET_PATH+x} ]; then
        echo
        echo -e " [\e[1;33mWARNING\e[0m] CARDANO_NODE_SOCKET_PATH env variable not set."
        echo "           It might cause dysfunctions if using cardano-cli."
        echo
    else
        echo -e " [\e[1;32mOK\e[0m] Cardano Node Socket Path :      "$CARDANO_NODE_SOCKET_PATH
    fi
    if [ -z ${NODE_CONFIG+x} ]; then
        echo
        echo -e " [\e[1;33mKO\e[0m] NODE_CONFIG env variable is not set."
        echo
    else
        echo -e " [\e[1;32mOK\e[0m] Cardano Node Mode :             "$NODE_CONFIG
    fi
    echo
    echo "#########################################################################"
    echo
    echo -e "\e[0;33m/////// CARDANO PRELIMINARY CHECKS /////// \e[0m"
    sleep 1
    echo
    echo -e " \e[1;32mCardano Node Version :\e[0m"
    echo
    CARDANO_NODE=$(cardano-node version)
    NODE_VERSION=$(echo $CARDANO_NODE | grep -o "cardano-node [0-9.]*" | awk '{print $2}')
    LATEST_VERSION=$(curl -s https://api.github.com/repositories/188299874/releases/latest | jq -r .tag_name)
    MAJOR_VERSION=$(echo $NODE_VERSION | cut -d '.' -f 1)
    MINOR_VERSION=$(echo $NODE_VERSION | cut -d '.' -f 2)
    if [ $NODE_VERSION = $LATEST_VERSION ] ; then
        echo -e " [\e[1;32mOK\e[0m] The latest Cardano Node version is installed"
        echo " Cardano Node version :   "$NODE_VERSION
    elif [ "$MAJOR_VERSION" -le 9 ] && [ "$MINOR_VERSION" -lt 1 ] ; then
        echo -e " [\e[1;31mKO\e[0m] \e[1;31mThe installed Cardano Node does not meet the minimum version requirements (>= 9.1) "
        echo -e " \e[1;31mPlease upgrade your Cardano Node to the latest version, as soon as possible ! "
        echo " Current version :    "$NODE_VERSION
        echo " Latest version :     "$LATEST_VERSION
        sleep 1
    else
        echo -e " [\e[1;33mWARNING\e[0m] The latest Cardano Node version is not installed"
        echo " Current version :    "$NODE_VERSION
        echo " Latest version :     "$LATEST_VERSION
        sleep 1
    fi
    echo

    SERVICE="/etc/systemd/system/cardano-node.service"
    if [ -f "$SERVICE" ] ; then
        echo -e " [\e[1;32mOK\e[0m] Systemd service file Cardano found :    "$SERVICE
        STARTCARDANO=$(grep "ExecStart" $SERVICE | cut -d "'" -f 2)
        if [ -f "$STARTCARDANO" ] ; then
            echo -e " [\e[1;32mOK\e[0m] Cardano Statup script found :           "$STARTCARDANO
            echo
            PORT_LINE=$(grep "PORT=" "$STARTCARDANO")
            HOSTADDR_LINE=$(grep "HOSTADDR=" "$STARTCARDANO")
            CONFIG_LINE=$(grep "CONFIG=" "$STARTCARDANO")
            TOPOLOGY_LINE=$(grep "TOPOLOGY=" "$STARTCARDANO")
            DB_PATH_LINE=$(grep "DB_PATH=" "$STARTCARDANO")
            SOCKET_PATH_LINE=$(grep "SOCKET_PATH=" "$STARTCARDANO")
            KES_LINE=$(grep "KES=" "$STARTCARDANO")
            VRF_LINE=$(grep "VRF=" "$STARTCARDANO")
            CERT_LINE=$(grep "CERT=" "$STARTCARDANO")
            if [ ! -z "$PORT_LINE" ] ; then
                PORT=$(echo "$PORT_LINE" | cut -d= -f2)
                echo -e " [\e[1;32mOK\e[0m] Cardano node listening port :       "$PORT
            else
                PORT="null"
                echo -e " [\e[1;31mKO\e[0m] Cardano node listening port not found"
            fi
            if [ ! -z "$HOSTADDR_LINE" ] ; then
                HOSTADDR=$(echo "$HOSTADDR_LINE" | cut -d= -f2)
                echo -e " [\e[1;32mOK\e[0m] Cardano node listening address :    "$HOSTADDR
            else
                HOSTADDR="null"
                echo -e " [\e[1;31mKO\e[0m] Cardano node listening address not found"
            fi
            if [ ! -z "$CONFIG_LINE" ] ; then
                CONFIG=$(echo "$CONFIG_LINE" | cut -d= -f2)
                echo -e " [\e[1;32mOK\e[0m] Cardano node config file :          "$CONFIG
            else
                CONFIG="null"
                echo -e " [\e[1;31mKO\e[0m] Cardano node config file not found !! Script won't work correctly !!"
            fi
            if [ ! -z "$TOPOLOGY_LINE" ] ; then
                TOPOLOGY=$(echo "$TOPOLOGY_LINE" | cut -d= -f2)
                echo -e " [\e[1;32mOK\e[0m] Cardano node topology file :        "$TOPOLOGY
            else
                echo -e " [\e[1;31mKO\e[0m] Cardano node topology file not found !! Script won't work correctly !!"
                TOPOLOGY="null"
            fi
            if [ ! -z "$KES_LINE" ] ; then
                KES=$(echo "$KES_LINE" | cut -d= -f2)
                echo -e " [\e[1;32mOK\e[0m] KES file :                          "$KES
            else
                echo -e " [\e[1;33mWARNING\e[0m] Cardano node KES file not found ! It may be normal if your node is a RELAY"
                KES="null"
            fi
            if [ ! -z "$VRF_LINE" ] ; then
                VRF=$(echo "$VRF_LINE" | cut -d= -f2)
                echo -e " [\e[1;32mOK\e[0m] VRF file :                          "$VRF
            else
                echo -e " [\e[1;33mWARNING\e[0m] Cardano node VRF file not found ! It may be normal if your node is a RELAY"
                VRF="null"
            fi
            if [ ! -z "$CERT_LINE" ] ; then
                CERT=$(echo "$CERT_LINE" | cut -d= -f2)
                echo -e " [\e[1;32mOK\e[0m] CERT file :                         "$CERT
            else
                echo -e " [\e[1;33mWARNING\e[0m] Cardano node CERT file not found ! It may be normal if your node is a RELAY"
                CERT="null"
            fi
        else
            echo -e " [\e[1;31mKO\e[0m] Could not find Cardano starting script inside Systemd service file"
            STARTCARDANO="null"
            PORT="null"
            HOSTADDR="null"
            CONFIG="null"
            TOPOLOGY="null"
            KES="null"
            VRF="null"
            CERT="null"
        fi
    else
        echo -e " [\e[1;31mKO\e[0m] Could not find systemd service file for Cardano. !! Script won't work correctly !!"
        STARTCARDANO="null"
        SERVICE="null"
        PORT="null"
        HOSTADDR="null"
        CONFIG="null"
        TOPOLOGY="null"
        KES="null"
        VRF="null"
        CERT="null"
    fi
    echo
    echo "#########################################################################"
    echo
    echo -e "\e[0;33m/////// NODE OPERATION CHECK /////// \e[0m"
    sleep 1
    echo
    if [ "$STARTCARDANO" != "null" ] ; then
        if grep -q "/usr/local/bin/cardano-node" "$STARTCARDANO" && grep -q -- "--shelley-kes-key" "$STARTCARDANO" && grep -q -- "--shelley-vrf-key" "$STARTCARDANO" && grep -q -- "--shelley-operational-certificate" "$STARTCARDANO" ; then
            echo -e " [\e[1;32mOK\e[0m] YOUR NODE SEEMS TO BE RUNNING AS A \e[1;32mBLOCK PRODUCER\e[0m"
            NODEMODE=BP
        else
            echo -e " [\e[1;32mOK\e[0m] YOUR NODE SEEMS TO BE RUNNING AS A \e[1;32mRELAY\e[0m"
            NODEMODE=RELAY
        fi
    else
        echo -e " [\e[1;33mWARNING\e[0m] Could not find your starting Cardano script while trying to parse systemd service file."
        echo -e "           Will try to look at other files to determine your operation node, but it might not be accurate..."
        echo
        sleep 1
        if [ -f "$NODE_HOME/topology.json" ] ; then

            if grep -qi "relays-new.cardano-mainnet.iohk.io\|backbone.cardano.iog.io\|backbone.mainnet.emurgornd.com\|backbone.cardano-mainnet.iohk.io" "$NODE_HOME/topology.json" && [ -f "$NODE_HOME/node.cert" ]; then
                echo -e " YOUR NODE SEEMS TO BE RUNNING AS A \e[1;32mBLOCK PRODUCER\e[0m"
                echo -e " (topology.json found without public relays + node.cert file found)"
                NODEMODE="BP"
            else
                echo -e " YOUR NODE SEEMS TO BE RUNNING AS A \e[1;31mRELAY\e[0m"
                echo -e " (topology.json contains public relays or node.cert file not found)"
                NODEMODE="Relay"
            fi
        else
            echo -e " [\e[1;31mKO\e[0m] Still unable to determine if your node is a Relay or a Block Producer"
            NODEMODE="NA"
        fi
    fi
    sleep 1

    ####################################### BLOCK PRODUCER CHECK #######################################


    if [ "$NODEMODE" == "BP" ] ; then
        echo
        echo "---------------------------------------------------------------------"
        echo " Topology check (topology.json)"
        echo "---------------------------------------------------------------------"
        echo
        sleep 1
        if [ "$CONFIG" != "null" ] && [ -r "$CONFIG" ] ; then
            if [[ "$(awk -F ":" '/"PeerSharing"/ {print $2}' $CONFIG)" == *"true"* ]] ; then
                echo -e " [\e[1;31mDANGER\e[0m] \e[1;31mPeerSharing is enabled. It MUST be disabled on your Block Producer (config.json)\e[0m"
            else
                echo -e " [\e[1;32mOK\e[0m] PeerSharing is set to 'false' (config.json)"
            fi
            echo
            if [[ "$(awk -F ":" '/"EnableP2P"/ {print $2}' $CONFIG)" == *"true"* ]] ; then
                echo -e " TOPOLOGY MODE : Your node seems to be running in \e[1;32mP2P mode\e[0m"
                echo " checking your topology... please wait"
                sleep 2
                echo "--------------------"
                PRODUCERS=$(jq '.Producers' $TOPOLOGY)
                if [ "$(echo $PRODUCERS | jq '. | length')" -gt 0 ]; then
                    echo -e " [\e[1;31mKO\e[0m] it seems you are using the Legacy Topology file. You must use the P2P Topology file"
                else
                    LOCALROOTS=$(jq '.localRoots' $TOPOLOGY)
                    if [ "$(echo $LOCALROOTS | jq '. | length')" -eq 0 ]; then
                        echo -e " [\e[1;31mKO\e[0m] localRoots block seems empty. You need to connect your Relay to your Block Producer"
                    else
                        echo -e " [\e[1;32mOK\e[0m] localRoots peer list :"
                        echo
                        ACCESS_POINTS=$(echo $LOCALROOTS | jq '.[].accessPoints')
                        if [ "$(echo $ACCESS_POINTS | jq '. | length')" -gt 0 ]; then
                            echo "$ACCESS_POINTS" | jq -r '.[] | "\(.address) \(.port)"'
                            echo
                        else
                            echo -e " [\e[1;31mKO\e[0m] accessPoints list seems empty. You need to connect your Relay to your Block Producer"
                        fi
                        if [ "$(echo $LOCALROOTS | jq '.[].advertise')" == "true" ]; then
                            echo -e " [\e[1;31mKO\e[0m] advertise is set to 'true'. You must not advertise your Block Producer"
                        else
                            echo -e " [\e[1;32mOK\e[0m] advertise is set to 'false' (good practice)"
                        fi
                        if [ "$(echo $LOCALROOTS | jq '.[].trustable')" == "false" ]; then
                            echo -e " [\e[1;31mKO\e[0m] trustable is set to 'false'. You must trust your Block Producer"
                        else
                            echo -e " [\e[1;32mOK\e[0m] trustable is set to 'true'"
                        fi
                        echo "--------------------"
                        PUBLICROOTS=$(jq '.publicRoots' $TOPOLOGY)
                        if [ "$(echo $PUBLICROOTS | jq '. | length')" -gt 0 ]; then
                            ACCESS_POINTS_PR=$(echo $PUBLICROOTS | jq '.[].accessPoints')
                            if [ "$(echo $ACCESS_POINTS_PR | jq '. | length')" -gt 0 ]; then
                                echo -e " [\e[1;31mDANGER\e[0m] \e[1;31mpublicRoots list is not empty. it MUST be empty. Your BP should only connect to your Relays\e[0m"
                            else
                                echo -e " [\e[1;32mOK\e[0m] publicRoots is empty (good practice)"
                            fi
                        fi
                    fi
                    echo "--------------------"
                    if grep -q '"useLedgerAfterSlot":' $TOPOLOGY; then
                        USELEDGER_VALUE=$(grep -oP '"useLedgerAfterSlot": \K-?[0-9]+' $TOPOLOGY)
                        if [ "$USELEDGER_VALUE" == "-1" ]; then
                            echo -e " [\e[1;32mOK\e[0m] useLedgerAfterSlot option set to -1 "
                        else 
                            echo -e " [\e[1;31mKO\e[0m] useLedgerAfterSlot should be set to -1 on your Block Producer"
                        fi
                    else
                        echo -e " [\e[1;31mKO\e[0m] useLedgerAfterSlot absent from your topology file"
                    fi
                fi
            else
            echo -e " TOPOLOGY MODE : Your node seems to be running \e[1;33mwithout P2P\e[0m"
            echo -e " [\033[1;33mWARNING\033[0m] You should enable P2P on your node, and properly configure it"   
            echo -e " Also, avoid connecting your non-P2P Block Producer to a P2P Relay with"
            echo -e " PeerSharing enabled as the Block Producer's IP will be leaked"
            echo
            echo " checking your topology (P2P off)... please wait"
            sleep 2
            echo "--------------------" 
            echo
                if [ "$TOPOLOGY" != "null" ] && [ -r "$TOPOLOGY" ] ; then
                    PRODUCERS=$(jq -r ".Producers[] | .addr + \":\" + (.port | tostring)" "$TOPOLOGY")
                    echo -e " [\e[1;32mOK\e[0m] Relay list :"
                    echo " $PRODUCERS" | tr ' ' '\n'
                else
                    echo -e " [\e[1;31mKO\e[0m] topology.json not found or not readable"
                fi
            fi
        
        else
            echo -e " [\e[1;31mKO\e[0m] config.json not found or not readable."
        fi
        echo
        echo "---------------------------------------------------------------------"
        echo " KEY files check"
        echo "---------------------------------------------------------------------"
        echo
        sleep 1
            if [ -f "$(echo $KES)" ] ; then
                PERMISSIONS_KES=$(stat -c "%a" $KES)
                if [ "$PERMISSIONS_KES" = 400 ] ; then
                    printf " [\033[1;32mOK\033[0m] kes.skey exists with right permissions (400).\n";
                else
                    printf " [\033[1;33mWARNING\033[0m] kes.skey exists with wrong permissions. You should chmod 400 kes.skey\n";
                fi
            else 
                printf " [\033[0;31mKO\033[0m] kes.skey not found on your Cardano Home\n";
            fi
            if [ -f "$(echo $VRF)" ] ; then
                PERMISSIONS_VRF=$(stat -c "%a" $VRF)
                if [ "$PERMISSIONS_VRF" = 400 ] ; then
                    printf " [\033[1;32mOK\033[0m] vrf.skey exists with right permissions (400).\n";
                else
                    printf " [\033[1;33mWARNING\033[0m] vrf.skey exists with wrong permissions. You should chmod 400 vrf.skey\n";
                fi
            else 
                printf " [\033[0;31mKO\033[0m] vrf.skey not found on your Cardano Home\n";
            fi
            if [ -f "$(echo $CERT)" ] ; then
                PERMISSIONS_CERT=$(stat -c "%a" $CERT)
                if [ "$PERMISSIONS_CERT" = 400 ] ; then
                    printf " [\033[1;32mOK\033[0m] node.cert exists with right permissions (400).\n";
                else
                    printf " [\033[1;33mWARNING\033[0m] node.cert exists with wrong permissions. You should chmod 400 node.cert\n";
                fi
            else 
                printf " [\033[0;31mKO\033[0m] node.cert not found on your Cardano Home\n";
            fi
            echo
        FINDTEST=$(find / -path /proc -prune -o -type f -name "node.vkey" -printf '%p\n')
            if [ -n "$FINDTEST" ]; then
                echo -e " \e[1;31mDANGER : node.vkey found.  $FINDTEST"
                echo -e " You should never let your node keys on your Block Producer"
                echo -e " Please make sure node.vkey is saved on your air-gapped machine and on a secure USB key, and remove it from BP\e[0m"
                echo
            else
                echo -e " [\e[1;32mOK\e[0m] node.vkey not found on the server (good practice)"        
            fi
        FINDTEST=$(find / -path /proc -prune -o -type f -name "node.skey" -printf '%p\n')
            if [ -n "$FINDTEST" ]; then
                echo -e " \e[1;31mDANGER : node.skey found.  $FINDTEST"
                echo -e " You should never let your node keys on your Block Producer"
                echo -e " Please make sure node.skey is saved on your air-gapped machine and on a secure USB key, and remove it from BP\e[0m"
                echo
            else
                echo -e " [\e[1;32mOK\e[0m] node.skey not found on the server (good practice)"        
            fi
        echo
        echo "---------------------------------------------------------------------"
        echo " KES keys rotation information"
        echo "---------------------------------------------------------------------"
        echo
        sleep 1
        cardano-cli query kes-period-info --mainnet  \
        --op-cert-file $NODE_HOME/node.cert
        echo
        KES_PERIOD_OUTPUT=$(cardano-cli query kes-period-info --mainnet --op-cert-file $CERT)
        EXPIRY_DATE=$(echo $KES_PERIOD_OUTPUT | grep -oP '"qKesKesKeyExpiry": "\K[^"]+')
        EXPIRY_TIMESTAMP=$(date -d "$EXPIRY_DATE" +%s)
        CURRENT_TIMESTAMP=$(date +%s)
        SECONDS_REMAINING=$((EXPIRY_TIMESTAMP - CURRENT_TIMESTAMP))
        DAYS_REMAINING=$((SECONDS_REMAINING / 86400))
        if [[ $DAYS_REMAINING -lt 1 ]]; then
            echo -e " \e[1;31mDANGER : KES key is about to expire in 1 day or has already expired !"
            echo -e " You must rotate your KES keys or your Cardano Node won't be able to validate blocks\e[0m"
        elif [[ $DAYS_REMAINING -lt 8 && $DAYS_REMAINING -gt 1 ]]; then
            echo -e " [\033[1;33mWARNING\033[0m] Remaining days before KES key expires : "$DAYS_REMAINING
        elif [[ $DAYS_REMAINING -lt 16 ]]; then
            echo -e " [\033[1;33mWARNING\033[0m] Remaining days before KES key expires : "$DAYS_REMAINING
        else
            echo -e " [\033[1;32mOK\033[0m] KES Key valid. Remaining days before expiry : "$DAYS_REMAINING
        fi
        echo

    ####################################### RELAY CHECK #######################################

    elif [ "$NODEMODE" == "RELAY" ] ; then
        echo
        echo "---------------------------------------------------------------------"
        echo " Topology check (topology.json)"
        echo "---------------------------------------------------------------------"
        echo
        sleep 1
        if [ "$CONFIG" != "null" ] && [ -r "$CONFIG" ] ; then
            if [[ "$(awk -F ":" '/"PeerSharing"/ {print $2}' $CONFIG)" == *"true"* ]] ; then
                echo -e " [\e[1;32mOK\e[0m] PeerSharing is set to 'true' (config.json)"
            else
                echo -e " [\e[1;31mKO\e[0m] PeerSharing is disabled. It MUST be enabled on your Relays (config.json)"
            fi
            echo
            if [[ "$(awk -F ":" '/EnableP2P/ {print $2}' $CONFIG)" == *"true"* ]] ; then
                echo -e " TOPOLOGY MODE : Your node seems to be running in \e[1;32mP2P mode\e[0m"
                echo " checking your topology... please wait"
                sleep 2
                echo "--------------------"
                PRODUCERS=$(jq '.Producers' $TOPOLOGY)
                if [ "$(echo $PRODUCERS | jq '. | length')" -gt 0 ]; then
                    echo -e " [\e[1;31mKO\e[0m] it seems you are using the Legacy Topology file. You must use the P2P Topology file"
                else
                    LOCALROOTS=$(jq '.localRoots' $TOPOLOGY)
                    if [ "$(echo $LOCALROOTS | jq '. | length')" -eq 0 ]; then
                        echo -e " [\e[1;31mKO\e[0m] localRoots block seems empty. You need to connect your Relay to your Block Producer"
                    else
                        echo -e " [\e[1;32mOK\e[0m] localRoots peer list :"
                        echo
                        ACCESS_POINTS=$(echo $LOCALROOTS | jq '.[].accessPoints')
                        if [ "$(echo $ACCESS_POINTS | jq '. | length')" -gt 0 ]; then
                            echo "$ACCESS_POINTS" | jq -r '.[] | "\(.address) \(.port)"'
                            echo
                        else
                            echo -e " [\e[1;31mKO\e[0m] accessPoints list seems empty. You need to connect your Relay to your Block Producer"
                        fi
                        if [ "$(echo $LOCALROOTS | jq '.[].advertise')" == "true" ]; then
                            echo -e " [\e[1;31mKO\e[0m] advertise is set to 'true'. You must not advertise your Block Producer"
                        else
                            echo -e " [\e[1;32mOK\e[0m] advertise is set to 'false' (good practice)"
                        fi
                        if [ "$(echo $LOCALROOTS | jq '.[].trustable')" == "false" ]; then
                            echo -e " [\e[1;31mKO\e[0m] trustable is set to 'false'. You must trust your Block Producer"
                        else
                            echo -e " [\e[1;32mOK\e[0m] trustable is set to 'true'"
                        fi
                        echo "--------------------"
                        BOOTSTRAP=$(jq '.bootstrapPeers' $TOPOLOGY)
                        if [ "$(echo $BOOTSTRAP | jq '. | length')" -gt 0 ]; then
                            echo -e " [\e[1;32mOK\e[0m] Your relay is running in Bootstrap Mode"
                            echo -e " [\e[1;32mOK\e[0m] Boostrap peer list :"
                            echo
                            echo "$BOOTSTRAP" | jq -r '.[] | "\(.address) \(.port)"'
                        else
                            echo -e " [\e[1;33mWARNING\e[0m] Bootstrap section not found or empty. Checking publicRoot section..."
                            PUBLICROOTS=$(jq '.publicRoots' $TOPOLOGY)
                            REQ=("backbone.mainnet.cardanofoundation.org" "backbone.cardano.iog.io" "backbone.mainnet.emurgornd.com")
                            ALLREQ=1
                            for string in "${REQ[@]}"; do
                                if [[ ! "$PUBLICROOTS" == *"$string"* ]]; then
                                    echo -e " [\e[1;33mWARNING\e[0m] Missing required Public Root: $string"
                                    ALLREQ=0
                                fi
                            done
                            if [[ "$ALLREQ" = 1 ]]; then
                                echo -e " [\e[1;32mOK\e[0m] All required PublicRoots found :"
                                echo
                                ACCESS_POINTS_PR=$(echo $PUBLICROOTS | jq '.[].accessPoints')
                                echo "$ACCESS_POINTS_PR" | jq -r '.[] | "\(.address) \(.port)"'
                            fi
                            if [[ "$PUBLICROOTS" == *'relays-new.cardano-mainnet.iohk.io'* ]]; then
                                echo -e " [\e[1;33mWARNING\e[0m] relays-new.cardano-mainnet.iohk.io in PublicRoots is deprecated."
                            fi
                        fi
                        echo "--------------------"
                        if grep -q '"useLedgerAfterSlot":' $TOPOLOGY; then
                            USELEDGER_VALUE=$(grep -oP '"useLedgerAfterSlot": \K[0-9]+' $TOPOLOGY)
                            if [ "$USELEDGER_VALUE" -ge 0 ]; then
                                echo -e " [\e[1;32mOK\e[0m] useLedgerAfterSlot is greater or equal to 0 "
                            else
                                echo -e " [\e[1;31mKO\e[0m] useLedgerAfterSlot must be set to 0 or more on your Relay"
                            fi
                        else
                            echo -e " [\e[1;31mKO\e[0m] useLedgerAfterSlot absent from your topology file"
                        fi
                    fi
                fi
            else
                echo -e " TOPOLOGY MODE : Your node seems to be running \e[1;31mwithout P2P\e[0m"
                echo -e " [\e[1;31mKO\e[0m] Please enable P2P mode, and configure it properly"
                echo " trying to check your topology (P2P off)... please wait"
                sleep 2
                echo "--------------------"
                PRODUCERS=$(grep -o '"addr": "[^"]*"' $TOPOLOGY)
                PRODUCERCOUNT=$(echo "$PRODUCERS" | wc -l)
                    if [[ "$PRODUCERCOUNT" -lt "10" ]] ; then
                        echo -e " [\e[1;33mWARNING\e[0m] Less than 10 peers found in topology.json. It should be around 20"
                    else    
                        echo -e " [\e[1;32mOK\e[0m] $PRODUCERCOUNT peers found in topology.json."
                    fi
                echo "--------------------"    
                TOPOLOGYUPDATER=$(find / -xdev -path /proc -prune -o -type f -name "topologyUpdater.sh" -printf '%p\n' -quit)
                if [[ -n "$TOPOLOGYUPDATER" ]]; then
                    echo -e " [\e[1;32mOK\e[0m] Topology Updater found: $TOPOLOGYUPDATER"
                    TOPOLOGYCRONJOB=$(grep -r -l -w topologyUpdater /var/spool/cron/crontabs/* 2>/dev/null)
                    if [[ -n "$TOPOLOGYCRONJOB" ]]; then
                        echo -e " [\e[1;32mOK\e[0m] A cron job has been found for Topology Updater. Make sure it runs every hour."
                        TOPOLOGYLOGS=$(tail -5 $HOME/cardano-my-node/logs/topologyUpdater_lastresult.json | grep -v 204)
                        if [[ -z "$TOPOLOGYLOGS" ]]; then
                            echo -e " [\e[1;32mOK\e[0m] Last 5 log lines results for Topology Updater are OK."
                        else
                            echo -e " [\e[1;33mWARNING\e[0m] Topology Updater might have some issues. Please check log messages:"
                            echo
                            echo "$TOPOLOGYLOGS"
                        fi
                    else
                        echo -e " [\e[0;31mKO\e[0m] No cron job found for Topology Updater. Make sure to create one that runs every hour."
                    fi
                else
                    echo -e " [\e[1;31mKO\e[0m] Topology Updater not found. Your Relay might not work correctly."
                fi
            fi
        else
            echo -e " [\e[1;31mKO\e[0m] config.json not found or not readable."
        fi
        echo
        echo "---------------------------------------------------------------------"
        echo " KEY files check"
        echo "---------------------------------------------------------------------"
        echo
        sleep 1
        FINDTEST=$(find / -path /proc -prune -o -type f -name "node.vkey" -printf '%p\n')
        if [ -n "$FINDTEST" ]; then
            echo -e " \e[1;31mDANGER : node.vkey found.  $FINDTEST"
            echo -e " You should never let your any key file on your Relay, especially node.vkey"
            echo -e " Please make sure node.vkey is saved on your air-gapped machine and on a secure USB key, and remove it from this node\e[0m"
        else
            echo -e " [\e[1;32mOK\e[0m] node.vkey not found on the server (good practice)"        
        fi
        FINDTEST=$(find / -path /proc -prune -o -type f -name "node.skey" -printf '%p\n')
        if [ -n "$FINDTEST" ]; then
            echo
            echo -e " \e[1;31mDANGER : node.skey found.  $FINDTEST"
            echo -e " You should never let your any key file on your Relay, especially node.skey"
            echo -e " Please make sure node.skey is saved on your air-gapped machine and on a secure USB key, and remove it from thos node\e[0m"
        else
            echo -e " [\e[1;32mOK\e[0m] node.skey not found on the server (good practice)"        
        fi

    ####################################### NOT A CARDANO NODE #######################################

    else
        echo
        echo "---------------------------------------------------------------------"
        echo " Cardano configuration could not be found. Skipping Cardano tests"
        echo "---------------------------------------------------------------------"
        sleep 1
    fi
fi
if [[ "$COINCASHEW_ANSWER_LOWER" == "no" ]]; then
    echo
    echo -e "\e[1;33mSCRIPT WILL ONLY DO SECURITY CHECKS\e[0m"
fi
    ####################################### SYSTEM AND SECURITY CHECK #######################################

echo
echo "#########################################################################"
echo
echo -e "\e[0;33m/////// SSHD CONFIG CHECK /////// \e[0m"
sleep 1
echo
SSHTEST=$(grep -i "Port" /etc/ssh/sshd_config | grep -v "#")
if [ "$(echo $SSHTEST | awk '{print $2}')" == 22 ]; then
    echo -e " [\e[1;31mKO\e[0m] SSH port should be different to 22"
else
    echo -e " [\e[1;32mOK\e[0m] SSH "$SSHTEST
fi

SSHTEST=$(grep -i "PasswordAuthentication no" /etc/ssh/sshd_config | grep -v "#")
    if [ -z "$SSHTEST" ]; then
        echo -e " [\e[1;31mKO\e[0m] PasswordAuthentication should be set to 'no'"
    else
        echo -e " [\e[1;32mOK\e[0m] "$SSHTEST
    fi

SSHTEST=$(grep -i "PermitRootLogin prohibit-password" /etc/ssh/sshd_config | grep -v "#")
    if [ -z "$SSHTEST" ]; then
        echo -e " [\e[1;31mKO\e[0m] PermitRootLogin should be set to 'prohibit-password'"
    else
        echo -e " [\e[1;32mOK\e[0m] "$SSHTEST
    fi

SSHTEST=$(grep -i "PermitEmptyPasswords no" /etc/ssh/sshd_config | grep -v "#")
    if [ -z "$SSHTEST" ]; then
        echo -e " [\e[1;31mKO\e[0m] PermitEmptyPasswords should be set to 'no'"
    else
        echo -e " [\e[1;32mOK\e[0m] "$SSHTEST
    fi

SSHTEST=$(grep -i "X11Forwarding no" /etc/ssh/sshd_config | grep -v "#")
    if [ -z "$SSHTEST" ]; then
        echo -e " [\e[1;31mKO\e[0m] X11Forwarding should be set to 'no'"
    else
        echo -e " [\e[1;32mOK\e[0m] "$SSHTEST
    fi

SSHTEST=$(grep -i "TCPKeepAlive no" /etc/ssh/sshd_config | grep -v "#")
    if [ -z "$SSHTEST" ]; then
        echo -e " [\e[1;31mKO\e[0m] TCPKeepAlive should be set to 'no'"
    else
        echo -e " [\e[1;32mOK\e[0m] "$SSHTEST
    fi

SSHTEST=$(grep -i "Compression no" /etc/ssh/sshd_config | grep -v "#")
    if [ -z "$SSHTEST" ]; then
        echo -e " [\e[1;31mKO\e[0m] Compression should be set to 'no'"
    else
        echo -e " [\e[1;32mOK\e[0m] "$SSHTEST
    fi

SSHTEST=$(grep -i "AllowAgentForwarding no" /etc/ssh/sshd_config | grep -v "#")
    if [ -z "$SSHTEST" ]; then
        echo -e " [\e[1;31mKO\e[0m] AllowAgentForwarding should be set to 'no'"
    else
        echo -e " [\e[1;32mOK\e[0m] "$SSHTEST
    fi

SSHTEST=$(grep -i "AllowTcpForwarding no" /etc/ssh/sshd_config | grep -v "#")
    if [ -z "$SSHTEST" ]; then
        echo -e " [\e[1;31mKO\e[0m] AllowTcpForwarding should be set to 'no'"
    else
        echo -e " [\e[1;32mOK\e[0m] "$SSHTEST
    fi

SSHTEST=$(grep -i "KbdInteractiveAuthentication no" /etc/ssh/sshd_config | grep -v "#")
    if [ -z "$SSHTEST" ]; then
        echo -e " [\e[1;31mKO\e[0m] KbdInteractiveAuthentication should be set to 'no' (unless using a 2FA method)"
    else
        echo -e " [\e[1;32mOK\e[0m] "$SSHTEST
    fi
echo
echo "#########################################################################"
echo
echo -e "\e[0;33m/////// SERVICES CHECK/////// \e[0m"
echo
sleep 1
    if [ "$(systemctl show -p SubState --value cardano-node)" == "running" ]; then
        echo -e " [\e[1;32mOK\e[0m] Service cardano-node is running"
    else
        echo -e " [\e[1;31mKO\e[0m] Service cardano-node is not running. Check your service status"
    fi
    if [ "$(systemctl show -p SubState --value chrony)" == "running" ]; then
        echo -e " [\e[1;32mOK\e[0m] Service chrony (ntp) is running"
    else
        echo -e " [\e[1;31mKO\e[0m] Service chrony (ntp) not running. Make sure you have a NTP sync service"
    fi
    if [ "$(systemctl is-active ufw)" == "active" ]; then
        echo -e " [\e[1;32mOK\e[0m] Service ufw (firewall) is active"
    else
        echo -e " [\e[1;31mKO\e[0m] Service ufw (firewall) is not active. Make sure you have a proper firewalling system up"
    fi
    if [ "$(systemctl show -p SubState --value unattended-upgrades)" == "running" ]; then
        echo -e " [\e[1;32mOK\e[0m] Service unattended-upgrades is running"
    else
        echo -e " [\e[1;31mKO\e[0m] Service unattended-upgrades is not running. You should setup automatic security updates"
    fi
    if [ "$(systemctl show -p SubState --value fail2ban)" == "running" ]; then
        echo -e " [\e[1;32mOK\e[0m] Service fail2ban is running"
    else
        echo -e " [\e[1;31mKO\e[0m] Service fail2ban is not running. You should setup fail2ban to harden access to your server"
    fi
echo
echo "#########################################################################"
echo
echo -e "\e[0;33m/////// NULL PASSWORDS CHECK /////// \e[0m"
echo
sleep 1
USERS="$(cut -d: -f 1 /etc/passwd)"
for x in $USERS
do
    NULL="$(passwd -S $x | grep 'NP')"
    if [[ ! -z $NULL ]] ; then
        echo $NULL
        PASSWDNULL="DETECTED"
    fi
done
if [[ -z $PASSWDNULL ]] ; then
    echo -e " [\e[1;32mOK\e[0m] No null password detected"
else
    echo -e " [\e[1;33mWARNING\e[0m] null password detected"
fi
echo
echo "#########################################################################"
echo
echo -e "\e[0;33m/////// FIREWALLING CHECK /////// \e[0m"
echo
sleep 1
echo -e "============ \e[1;33m iptables rules\e[0m =============="
echo ""

iptables-save | awk '/^-A/ && ($0 ~ /user-input/ || $0 ~ /f2b/ || $0 ~ /INPUT -p/) {print}'

echo ""
echo "=========================================="
echo
echo " --> This iptables extract includes every rules that have been manually added with UFW, or by Fail2ban"
echo
echo
echo "#########################################################################"
echo
echo -e "\e[0;33m/////// /etc/sysctl.conf HARDENING /////// \e[0m"
echo
sleep 1
echo -e " \e[0;33m### Avoid smurf attacks\e[0m"
echo
expected_value="1"
if grep -qE "^net.ipv4.icmp_echo_ignore_broadcasts\s*=\s*$expected_value" /etc/sysctl.conf ; then
    echo -e " [\033[1;32mOK\033[0m] net.ipv4.icmp_echo_ignore_broadcasts = 1"
else
    if grep -qE "^net.ipv4.icmp_echo_ignore_broadcasts" /etc/sysctl.conf ; then
        current_value=$(grep -E "^net.ipv4.icmp_echo_ignore_broadcasts" /etc/sysctl.conf | awk -F= '{print $2}' | tr -d '[:space:]')
        echo -e " [\033[1;33mWARNING\033[0m] net.ipv4.icmp_echo_ignore_broadcasts = "$current_value " Expected value : "$expected_value
    else
        echo -e " [\033[0;31mKO\033[0m] Not found. You should add : net.ipv4.icmp_echo_ignore_broadcasts = 1"
    fi
fi
sleep 1
echo
echo -e " \e[0;33m### Bad ICMP error messages protection\e[0m"
echo
expected_value="1"
if grep -qE "^net.ipv4.icmp_ignore_bogus_error_responses\s*=\s*$expected_value" /etc/sysctl.conf; then
    echo -e " [\033[1;32mOK\033[0m] net.ipv4.icmp_ignore_bogus_error_responses = 1"
else
    if grep -qE "^net.ipv4.icmp_ignore_bogus_error_responses" /etc/sysctl.conf; then
        current_value=$(grep -E "^net.ipv4.icmp_ignore_bogus_error_responses" /etc/sysctl.conf | awk -F= '{print $2}' | tr -d '[:space:]')
        echo -e " [\033[1;33mWARNING\033[0m] net.ipv4.icmp_ignore_bogus_error_responses = "$current_value " Expected value : "$expected_value
else
        echo -e " [\033[0;31mKO\033[0m] Not found. You should add : net.ipv4.icmp_ignore_bogus_error_responses = 1"
    fi
fi
sleep 1
echo
echo -e " \e[0;33m### SYN flood attack protection\e[0m"
echo
expected_value="1"
if grep -qE "^net.ipv4.tcp_syncookies\s*=\s*$expected_value" /etc/sysctl.conf; then
    echo -e " [\033[1;32mOK\033[0m] net.ipv4.tcp_syncookies = 1"
else
    if grep -qE "^net.ipv4.tcp_syncookies" /etc/sysctl.conf; then
        current_value=$(grep -E "^net.ipv4.tcp_syncookies" /etc/sysctl.conf | awk -F= '{print $2}' | tr -d '[:space:]')
        echo -e " [\033[1;33mWARNING\033[0m] net.ipv4.tcp_syncookies = "$current_value " Expected value : "$expected_value
else
        echo -e " [\033[0;31mKO\033[0m] Not found. You should add : net.ipv4.tcp_syncookies = 1"
    fi
fi

echo
echo -e " \e[0;33m### Disable Redirects\e[0m"
echo
expected_value="0"
if grep -qE "^net.ipv4.conf.all.accept_redirects\s*=\s*$expected_value" /etc/sysctl.conf; then
    echo -e " [\033[1;32mOK\033[0m] net.ipv4.conf.all.accept_redirects = 0"
else
    if grep -qE "^net.ipv4.conf.all.accept_redirects" /etc/sysctl.conf; then
        current_value=$(grep -E "^net.ipv4.conf.all.accept_redirects" /etc/sysctl.conf | awk -F= '{print $2}' | tr -d '[:space:]')
        echo -e " [\033[1;33mWARNING\033[0m] net.ipv4.conf.all.accept_redirects = "$current_value " Expected value : "$expected_value
else
        echo -e " [\033[0;31mKO\033[0m] Not found. You should add : net.ipv4.conf.all.accept_redirects = 0"
    fi
fi
if grep -qE "^net.ipv4.conf.default.accept_redirects\s*=\s*$expected_value" /etc/sysctl.conf; then
    echo -e " [\033[1;32mOK\033[0m] net.ipv4.conf.default.accept_redirects = 0"
else
    if grep -qE "^net.ipv4.conf.default.accept_redirects" /etc/sysctl.conf; then
        current_value=$(grep -E "^net.ipv4.conf.default.accept_redirects" /etc/sysctl.conf | awk -F= '{print $2}' | tr -d '[:space:]')
        echo -e " [\033[1;33mWARNING\033[0m] net.ipv4.conf.default.accept_redirects = "$current_value " Expected value : "$expected_value
else
        echo -e " [\033[0;31mKO\033[0m] Not found. You should add : net.ipv4.conf.default.accept_redirects = 0"
    fi
fi
if grep -qE "^net.ipv4.conf.all.secure_redirects\s*=\s*$expected_value" /etc/sysctl.conf; then
    echo -e " [\033[1;32mOK\033[0m] net.ipv4.conf.all.secure_redirects = 0"
else
    if grep -qE "^net.ipv4.conf.all.secure_redirects" /etc/sysctl.conf; then
        current_value=$(grep -E "^net.ipv4.conf.all.secure_redirects" /etc/sysctl.conf | awk -F= '{print $2}' | tr -d '[:space:]')
        echo -e " [\033[1;33mWARNING\033[0m] net.ipv4.conf.all.secure_redirects = "$current_value " Expected value : "$expected_value
else
        echo -e " [\033[0;31mKO\033[0m] Not found. You should add : net.ipv4.conf.all.secure_redirects = 0"
    fi
fi

echo
echo -e " \e[0;33m### Disable packet forwarding\e[0m"
echo
expected_value="0"
if grep -qE "^net.ipv4.ip_forward\s*=\s*$expected_value" /etc/sysctl.conf; then
    echo -e " [\033[1;32mOK\033[0m] net.ipv4.ip_forward = 0"
else
    if grep -qE "^net.ipv4.ip_forward" /etc/sysctl.conf; then
        current_value=$(grep -E "^net.ipv4.ip_forward" /etc/sysctl.conf | awk -F= '{print $2}' | tr -d '[:space:]')
        echo -e " [\033[1;33mWARNING\033[0m] net.ipv4.ip_forward = "$current_value " Expected value : "$expected_value
else
        echo -e " [\033[0;31mKO\033[0m] Not found. You should add : net.ipv4.ip_forward = 0"
    fi
fi

echo
echo -e " \e[0;33m### Synflood protection\e[0m"
echo
expected_value="5"
if grep -qE "^net.ipv4.tcp_synack_retries\s*=\s*$expected_value" /etc/sysctl.conf; then
    echo -e " [\033[1;32mOK\033[0m] net.ipv4.tcp_synack_retries = 5"
else
    if grep -qE "^net.ipv4.tcp_synack_retries" /etc/sysctl.conf; then
        current_value=$(grep -E "^net.ipv4.tcp_synack_retries" /etc/sysctl.conf | awk -F= '{print $2}' | tr -d '[:space:]')
        echo -e " [\033[1;33mWARNING\033[0m] net.ipv4.tcp_synack_retries = "$current_value " A fine value would be : "$expected_value
else
        echo -e " [\033[0;31mKO\033[0m] Not found. You should add : net.ipv4.tcp_synack_retries = 5"
    fi
fi

echo
echo -e " \e[0;33m### Refuse source routed packets\e[0m"
echo
expected_value="0"
if grep -qE "^net.ipv4.conf.all.accept_source_route\s*=\s*$expected_value" /etc/sysctl.conf; then
    echo -e " [\033[1;32mOK\033[0m] net.ipv4.conf.all.accept_source_route = 0"
else
    if grep -qE "^net.ipv4.conf.all.accept_source_route" /etc/sysctl.conf; then
        current_value=$(grep -E "^net.ipv4.conf.all.accept_source_route" /etc/sysctl.conf | awk -F= '{print $2}' | tr -d '[:space:]')
        echo -e " [\033[1;33mWARNING\033[0m] net.ipv4.conf.all.accept_source_route = "$current_value " Expected value : "$expected_value
else
        echo -e " [\033[0;31mKO\033[0m] Not found. You should add : net.ipv4.conf.all.accept_source_route = 0"
    fi
fi
if grep -qE "^net.ipv4.conf.default.accept_source_route\s*=\s*$expected_value" /etc/sysctl.conf; then
    echo -e " [\033[1;32mOK\033[0m] net.ipv4.conf.default.accept_source_route = 0"
else
    if grep -qE "^net.ipv4.conf.default.accept_source_route" /etc/sysctl.conf; then
        current_value=$(grep -E "^net.ipv4.conf.default.accept_source_route" /etc/sysctl.conf | awk -F= '{print $2}' | tr -d '[:space:]')
        echo -e " [\033[1;33mWARNING\033[0m] net.ipv4.conf.default.accept_source_route = "$current_value " Expected value : "$expected_value
else
        echo -e " [\033[0;31mKO\033[0m] Not found. You should add : net.ipv4.conf.default.accept_source_route = 0"
    fi
fi
sleep 1
echo
echo -e " \e[0;33m### Log spoofed, source routed, and redirect packets\e[0m"
echo
expected_value="1"
if grep -qE "^net.ipv4.conf.all.log_martians\s*=\s*$expected_value" /etc/sysctl.conf; then
    echo -e " [\033[1;32mOK\033[0m] net.ipv4.conf.all.log_martians = 1"
else
    if grep -qE "^net.ipv4.conf.all.log_martians" /etc/sysctl.conf; then
        current_value=$(grep -E "^net.ipv4.conf.all.log_martians" /etc/sysctl.conf | awk -F= '{print $2}' | tr -d '[:space:]')
        echo -e " [\033[1;33mWARNING\033[0m] net.ipv4.conf.all.log_martians = "$current_value " Expected value : "$expected_value
else
        echo -e " [\033[0;31mKO\033[0m] Not found. You should add : net.ipv4.conf.all.log_martians = 1"
    fi
fi
if grep -qE "^net.ipv4.conf.default.log_martians\s*=\s*$expected_value" /etc/sysctl.conf; then
    echo -e " [\033[1;32mOK\033[0m] net.ipv4.conf.default.log_martians = 1"
else
    if grep -qE "^net.ipv4.conf.default.log_martians" /etc/sysctl.conf; then
        current_value=$(grep -E "^net.ipv4.conf.default.log_martians" /etc/sysctl.conf | awk -F= '{print $2}' | tr -d '[:space:]')
        echo -e " [\033[1;33mWARNING\033[0m] net.ipv4.conf.default.log_martians = "$current_value " Expected value : "$expected_value
else
        echo -e " [\033[0;31mKO\033[0m] Not found. You should add : net.ipv4.conf.default.log_martians = 1"
    fi
fi

echo
echo -e " \e[0;33m### Increase TCP max buffer size\e[0m"
echo
expected_value="4096 87380 8388608"
if grep -qE "^net.ipv4.tcp_rmem\s*=\s*$expected_value" /etc/sysctl.conf; then
    echo -e " [\033[1;32mOK\033[0m] net.ipv4.tcp_rmem = 4096 87380 8388608"
else
    if grep -qE "^net.ipv4.tcp_rmem" /etc/sysctl.conf; then
        current_value=$(grep -E "^net.ipv4.tcp_rmem" /etc/sysctl.conf | awk -F= '{print $2}' | tr -d '[:space:]')
        echo -e " [\033[1;33mWARNING\033[0m] net.ipv4.tcp_rmem = "$current_value " A fine value would be : "$expected_value
else
        echo -e " [\033[0;31mKO\033[0m] Not found. You should add : net.ipv4.tcp_rmem = "$expected_value
    fi
fi
if grep -qE "^net.ipv4.tcp_wmem\s*=\s*$expected_value" /etc/sysctl.conf; then
    echo -e " [\033[1;32mOK\033[0m] net.ipv4.tcp_wmem = 4096 87380 8388608"
else
    if grep -qE "^net.ipv4.tcp_wmem" /etc/sysctl.conf; then
        current_value=$(grep -E "^net.ipv4.tcp_wmem" /etc/sysctl.conf | awk -F= '{print $2}' | tr -d '[:space:]')
        echo -e " [\033[1;33mWARNING\033[0m] net.ipv4.tcp_wmem = "$current_value " A fine value would be : "$expected_value
    else
        echo -e " [\033[0;31mKO\033[0m] Not found. You should add : net.ipv4.tcp_wmem = "$expected_value
    fi
fi
echo
echo "#########################################################################"
echo
END=$(date +%s)
DIFF=$(( $END - $START ))
echo -e "\e[0;36mScript completed in $DIFF seconds\e[0m"
echo
echo -e "\e[0;36mExecuted on : $(date)\e[0m"
echo 
if [[ "$EXPORT_ANSWER_LOWER" == "yes" ]]; then
    echo -e "\e[0;36mAudit results have been exported to $output_file\e[0m"
fi
exit 0
