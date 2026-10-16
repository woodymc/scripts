#!/bin/sh

wg_server_name='wg0'
wg_client_name=''

HelpShow() {
	echo ""
	echo "Usage: $0 -c name [ -i name ]"
	echo -e "\t-c client name"
	echo -e "\t-i server interface name"
	exit 1 # Exit script after printing help
}

while getopts ":c:i:h" opt; do
	case "$opt" in
		c) wg_client_name="$OPTARG";;
		i) wg_server_name="$OPTARG";;
		h) HelpShow; exit 0;;
		:) echo "write -$OPTARG param"; exit 2;;
		\?) echo "Use -h flag for help."; exit 2;; # Print case parameter is non-existent
	esac
done

WG_CFG_PATH="/etc/wireguard/$wg_server_name.conf"

if [ -z "$wg_client_name" ]; then
	echo "write client [-c] param"; exit
else
	if [ ! -f $WG_CFG_PATH ] || [ ! -f /etc/wireguard/$wg_server_name/public.key ]; then 
		echo "not found $wg_server_name config files"; exit
	fi
fi

CLIENT_CFG_PATH="/etc/wireguard/$wg_client_name"

serverPort=$(grep "ListenPort" $WG_CFG_PATH | awk -F '= ' '{print $2}')
serverAddr=$(grep "Address" $WG_CFG_PATH | awk '{split($3,a,"/"); print a[1]}')

if [ ! -d "$CLIENT_CFG_PATH" ]; then mkdir $CLIENT_CFG_PATH; fi

clientPrivateKey=$(wg genkey | tee $CLIENT_CFG_PATH/private.key)
chmod go= $CLIENT_CFG_PATH/private.key
clientPublicKey=$(cat $CLIENT_CFG_PATH/private.key | wg pubkey | tee $CLIENT_CFG_PATH/public.key)

lastClientAddr=$(grep "AllowedIPs" $WG_CFG_PATH | tail -1 | awk -F ' ' '{ print $3 }')
if [ -z "$lastClientAddr" ]; then 
	lastClientAddr=$serverAddr
fi
clientIP=$(echo $lastClientAddr | cut -d. -f1,2,3).$(($( echo echo $lastClientAddr | awk '{split($2,a,".") ;print a[4]}') + 1))
server_public_ip=$(curl ifconfig.io -4 --silent)
serverPublicKey=$(cat /etc/wireguard/$wg_server_name/public.key)

cat <<EOF > $CLIENT_CFG_PATH/client.conf
[Interface]
PrivateKey = $clientPrivateKey
Address = $clientIP
MTU = 1420
Table = off

[Peer]
PublicKey = $serverPublicKey
Endpoint = $server_public_ip:$serverPort
AllowedIPs = 0.0.0.0/0
PersistentKeepalive = 120
EOF

cat <<EOF >> $WG_CFG_PATH

[Peer]
PublicKey = $clientPublicKey
AllowedIPs = $clientIP
EOF
