#!/bin/bash
#
tput clear
trap ctrl_c INT

function ctrl_c() {
        echo "**You pressed Ctrl+C...Exiting"
        exit 0;
}

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
echo "v2.0.1" 
echo "by FRADA stake pool"
echo
echo "#########################################################################"
echo "Audit script for your cardano node installation with Coincashew guide"
echo "#########################################################################"
echo
echo "This script will collect and analyse info about your Cardano Node."
echo "It can help you harden your security, and check if your node configuration"
echo "is correct. It is designed for a Coincashew installation, but could be"
echo "modify to suit other setups."
echo 
echo "Tested for Ubuntu 22.04.2 LTS"
echo
echo "#########################################################################"
echo
echo "Script Starts in 3 seconds"
sleep 1
echo "2"
sleep 1
echo "1"
sleep 1
START=$(date +%s)
echo
echo -e "\e[0;33m 1. ENVIRONNEMENT VARIABLES CHECK/////// \e[0m"
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
echo -e "\e[0;33m 2. CARDANO PRELIMINARY CHECKS/////// \e[0m"
sleep 1
echo
echo -e " \e[1;32mCardano Node Version :\e[0m"
echo
cardano-node version
echo
echo -e " \e[1;32mCardano Cli Version :\e[0m"
echo
cardano-cli version
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
echo -e "\e[0;33m 3. NODE OPERATION CHECK/////// \e[0m"
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
        if [ "$(grep -i "relays-new.cardano-mainnet.iohk.io" $NODE_HOME/topology.json | grep -v "#")" == "" ] && [ -f "$NODE_HOME/node.cert" ] ; then
            echo -e " YOUR NODE SEEMS TO BE RUNNING AS A \e[1;32mBLOCK PRODUCER\e[0m"
            echo -e " (topology.json found without 'relays-new.cardano-mainnet.iohk.io' inside + and node.cert file found)"
            NODEMODE="BP"
        else
            echo -e " YOUR NODE SEEMS TO BE RUNNING AS A \e[1;32mRELAY\e[0m"
            NODEMODE="RELAY"
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
    echo " Topology check"
    echo "---------------------------------------------------------------------"
    echo
    sleep 1
        if [ "$CONFIG" != "null" ] && [ -r "$CONFIG" ] ; then
            if [[ "$(awk -F ":" '/"EnableP2P"/ {print $2}' $CONFIG)" == *"true"* ]] ; then
                echo -e " TOPOLOGY MODE : Your node seems to be running in \e[1;32mP2P mode\e[0m"
                echo " checking your topology... please wait"
                sleep 2
                echo
                if [[ "$(awk -F ":" '/"localRoots"/ {print $2}' $TOPOLOGY)" == *"[]"* ]] ; then
                    echo -e " [\e[1;31mKO\e[0m] localRoots block seems empty. You need to connect your Block Producer to your Relays"
                else
                    echo -e " [\e[1;32mOK\e[0m] localRoots peer list :"
                    echo
                    awk -v RS="publicRoots" '/localRoots/ {print $0}' $TOPOLOGY | awk '/address/ {print $0} '
                    echo
                fi
                if [[ "$(awk -F ":" '/"publicRoots"/ {print $2}' $TOPOLOGY)" == *"[]"* ]] ; then
                echo -e " [\e[1;32mOK\e[0m] PublicRoots is empty (good practice)"
                    if [[ "$(awk -F ":" '/"advertise"/ {print $2}' $TOPOLOGY)" == *"true"* ]] ; then
                    echo -e " [\e[1;31mKO\e[0m] You should not activate the advertise option on your Block Producer. Turn it to 'false'"
                    else
                    echo -e " [\e[1;32mOK\e[0m] Advertise option set to false (good practice) "
                    fi
                else
                echo -e " [\e[1;31mKO\e[0m] You should not have any PublicRoots server on your Block Producer. Leave it empty []"
                fi
            else
            echo -e " TOPOLOGY MODE : Your node seems to be running \e[1;32mwithout P2P\e[0m"   
            echo " checking your topology... please wait"
            sleep 2
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
        else
            echo -e " [\e[1;32mOK\e[0m] node.vkey not found on the server (good practice)"        
        fi
    echo
    FINDTEST=$(find / -path /proc -prune -o -type f -name "node.skey" -printf '%p\n')
        if [ -n "$FINDTEST" ]; then
            echo -e " \e[1;31mDANGER : node.skey found.  $FINDTEST"
            echo -e " You should never let your node keys on your Block Producer"
            echo -e " Please make sure node.skey is saved on your air-gapped machine and on a secure USB key, and remove it from BP\e[0m"
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
    echo " Topology check"
    echo "---------------------------------------------------------------------"
    echo
    sleep 1
    if [ "$CONFIG" != "null" ] && [ -r "$CONFIG" ] ; then
        if [[ "$(awk -F ":" '/EnableP2P/ {print $2}' $CONFIG)" == *"true"* ]] ; then
            echo -e " TOPOLOGY MODE : Your node seems to be running in \e[1;32mP2P mode\e[0m"
            echo " checking your topology... please wait"
            sleep 2
            echo
                if [[ "$(awk -F ":" '/"localRoots"/ {print $2}' $TOPOLOGY)" == *"[]"* ]] ; then
                    echo -e " [\e[1;31mKO\e[0m] localRoots block seems empty. You need to connect your Relay to your Block Producer"
                else
                    echo -e " [\e[1;32mOK\e[0m] localRoots peer list :"
                    echo
                    awk -v RS="publicRoots" '/localRoots/ {print $0}' $TOPOLOGY | awk '/address/ {print $0} '
                    echo
                fi
                if [[ "$(awk -F ":" '/"publicRoots"/ {print $2}' $TOPOLOGY)" == *"[]"* ]] ; then
                    echo -e " [\e[1;31mKO\e[0m] publicRoots block seems empty. Your Relay need to advertise to a Public Root"
                else
                    PUBLICROOT=$(awk '/publicRoots/ {n = 10} n {print prev;} {prev = $0} END {if (n) print}' $TOPOLOGY)
                        if [[ "$PUBLICROOT" == *'"relays-new.cardano-mainnet.iohk.io"'* ]] ; then
                            echo -e " [\e[1;32mOK\e[0m] PublicRoots is set to relays-new.cardano-mainnet.iohk.io (good practice) "
                        else
                            echo -e " [\e[1;31mKO\e[0m] relays-new.cardano-mainnet.iohk.io seems to be missing in your PublicRoots section"
                        fi
                fi
                if [[ "$PUBLICROOT" == *"advertise"* ]] && [[ "$PUBLICROOT" == *"true"* ]] ; then
                    echo -e " [\e[1;32mOK\e[0m] Advertise is set to 'true'"
                else
                    echo -e " [\e[1;31mKO\e[0m] Advertise seems to be set to 'false'. You have to set it to 'true' on your Relay"
                fi
        else
            echo -e " TOPOLOGY MODE : Your node seems to be running \e[1;32mwithout P2P\e[0m"
            echo " checking your topology... please wait"
            sleep 2
            echo
            PRODUCERS=$(grep -o '"addr": "[^"]*"' $TOPOLOGY)
            PRODUCERCOUNT=$(echo "$PRODUCERS" | wc -l)
                if [[ "$PRODUCERCOUNT" -lt "10" ]] ; then
                    echo -e " [\e[1;33mWARNING\e[0m] Less than 10 peers found in topology.json. It should be around 20"
                else    
                    echo -e " [\e[1;32mOK\e[0m] $PRODUCERCOUNT peers found in topology.json."
                fi
            TOPOLOGYUPDATER=$(find / -xdev -path /proc -prune -o -type f -name "topologyUpdater.sh" -printf '%p\n' -quit)
                if [[ -n "$TOPOLOGYUPDATER" ]]; then
                    echo -e " [\e[1;32mOK\e[0m] Topology Updater found: $TOPOLOGYUPDATER"
                    TOPOLOGYCRONJOB=$(grep -r -l -w topologyUpdater /var/spool/cron/crontabs/* 2>/dev/null)
                        if [[ -n "$TOPOLOGYCRONJOB" ]]; then
                            echo -e " [\e[1;32mOK\e[0m] A cron job has been found for Topology Updater. Make sure it runs every hour."
                            TOPOLOGYLOGS=$(tail -5 /home/kirael/cardano-my-node/logs/topologyUpdater_lastresult.json | grep -v 204)
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

####################################### SYSTEM AND SECURITY CHECK #######################################

echo
echo "#########################################################################"
echo
echo -e "\e[0;33m 4. SSHD CONFIG CHECK/////// \e[0m"
sleep 1
echo
SSHTEST=$(grep -i "Port" /etc/ssh/sshd_config | grep -v "#")
    if [ $(echo $SSHTEST | awk '{print $2}') == 22 ]; then
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
echo -e "\e[0;33m 5. SERVICES CHECK/////// \e[0m"
echo
sleep 1
    if [ $(systemctl show -p SubState --value cardano-node) == "running" ]; then
        echo -e " [\e[1;32mOK\e[0m] Service cardano-node is running"
    else
        echo -e " [\e[1;31mKO\e[0m] Service cardano-node is not running. Check your service status"
    fi
    if [ $(systemctl show -p SubState --value chrony) == "running" ]; then
        echo -e " [\e[1;32mOK\e[0m] Service chrony (ntp) is running"
    else
        echo -e " [\e[1;31mKO\e[0m] Service chrony (ntp) not running. Make sure you have a NTP sync service"
    fi
    if [ $(systemctl is-active ufw) == "active" ]; then
        echo -e " [\e[1;32mOK\e[0m] Service ufw (firewall) is active"
    else
        echo -e " [\e[1;31mKO\e[0m] Service ufw (firewall) is not active. Make sure you have a proper firewalling system up"
    fi
    if [ $(systemctl show -p SubState --value unattended-upgrades) == "running" ]; then
        echo -e " [\e[1;32mOK\e[0m] Service unattended-upgrades is running"
    else
        echo -e " [\e[1;31mKO\e[0m] Service unattended-upgrades is not running. You should setup automatic security updates"
    fi
    if [ $(systemctl show -p SubState --value fail2ban) == "running" ]; then
        echo -e " [\e[1;32mOK\e[0m] Service fail2ban is running"
    else
        echo -e " [\e[1;31mKO\e[0m] Service fail2ban is not running. You should setup fail2ban to harden access to your server"
    fi
echo
echo "#########################################################################"
echo
echo -e "\e[0;33m 6. NULL PASSWORDS CHECK/////// \e[0m"
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
echo -e "\e[0;33m 7. FIREWALLING CHECK/////// \e[0m"
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
echo -e "\e[0;33m 8. /etc/sysctl.conf HARDENING/////// \e[0m"
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
echo "Script completed in" $DIFF "seconds"
echo
echo "Executed on :"
date
echo
exit 0;
