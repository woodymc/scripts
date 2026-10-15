#!/bin/sh

PKG='wireguard'
WG_CFG_PATH='/etc/wireguard/'
WG_NAME_DEF='wg0'
WG_GATEWAY='10.88.0.1/24'
WG_IN_PORT='55055'

wg_server_name=$WG_NAME_DEF

HelpShow() {
	echo ""
	echo "Usage: $0 [ -s name ]"
	echo -e "\t-s server interface name"
	exit 1 # Exit script after printing help
}

while getopts ":s:h" opt; do
	case "$opt" in
		s) wg_server_name="$OPTARG";;
		h) HelpShow; exit 0;;
		:) echo "write -$OPTARG param"; exit 2;;
		\?) echo "Use -h flag for help."; exit 2;; # Print case parameter is non-existent
	esac
done

dpkg-query --show $PKG > /dev/null
if [ "$?" != "0" ]; then
	apt update && apt upgrade -y
	apt install $PKG -y
fi

SERVER_KEY_PATH="/etc/wireguard/$wg_server_name"
if [ ! -d "$SERVER_KEY_PATH" ]; then mkdir $SERVER_KEY_PATH; fi

serverPrivateKey=$(wg genkey | tee $SERVER_KEY_PATH/private.key)
chmod go= $SERVER_KEY_PATH/private.key
serverPublicKey=$(cat $SERVER_KEY_PATH/private.key | wg pubkey | tee $SERVER_KEY_PATH/public.key)
chmod go= $SERVER_KEY_PATH/public.key

def_sys_int=$(ip route list default | awk -F "dev " '{ print $2 }' | cut -d ' ' -f1)

cat <<EOF > $WG_CFG_PATH$wg_server_name.conf
[Interface]
PrivateKey = $serverPrivateKey
Address = $WG_GATEWAY
ListenPort = $WG_IN_PORT
PostUp = iptables -A FORWARD -i $wg_server_name -j ACCEPT; iptables -t nat -A POSTROUTING -o $def_sys_int -j MASQUERADE 
PostDown = iptables -D FORWARD -i $wg_server_name -j ACCEPT; iptables -t nat -D POSTROUTING -o $def_sys_int -j MASQUERADE
EOF

FILEPATH='/etc/sysctl.conf'
PARAM='net.ipv4.ip_forward='
if ( grep -q '#'$PARAM $FILEPATH ); then
	sed -i "s;#${PARAM}.*;${PARAM}1;" $FILEPATH
else 
	if ( grep -q $PARAM $FILEPATH ); then
		sed -i "s;${PARAM}.*;${PARAM}1;" $FILEPATH
	else
		echo "${PARAM}1" >> $FILEPATH
	fi
fi
sysctl -p
