#!/bin/sh

FILE_PATH='/etc/config/frpc'	# default path of config file to frp client 

server_addr='192.168.1.1'	# ip or hostname frp server 
server_port='7000'		# connect port to frp server
token='12345678-9abc-def0-1234-56789abcdef0'	# token frp

local_ip='127.0.0.1'	# localhost or ip to forward port
ssh_local_port=22	# default ssh port
ssh_remote_port=4000	# start port for client
web_local_port=80	# default web port
web_remote_port=8000	# start port for client

client=0

re='^[0-9]+$'

HelpShow()	{
	echo ""
	echo "Usage: $0 -a addr -c client -p port -t token"
	echo -e "\t-a url or IP of FRPS"
	echo -e "\t-c number of client"
 	echo -e "\t-p port of FRPS"
	echo -e "\t-t token of FRPS"
	exit 1 # Exit script after printing help
}

while getopts "a:c:hp:t:" opt; do
	case "$opt" in
		a ) server_addr=$OPTARG;;
		c ) if [[ "$OPTARG" =~ ^[0-9]+$ ]]; then client=$OPTARG; else echo "Input argument -c $OPTARG is not number"; exit; fi;;
		h ) HelpShow;;
		p ) if [[ "$OPTARG" =~ ^[0-9]+$ ]]; then server_port=$OPTARG; else echo "Input argument -p $OPTARG is not number"; exit; fi;;
		t ) token=$OPTARG;;
		? ) echo "Use -h flag for help."; exit;; # Print case parameter is non-existent
	esac
done

opkg update && opkg install frpc

ssh_remote_port=$(( $ssh_remote_port + $client ))
web_remote_port=$(( $web_remote_port + $client ))

cat <<EOF >$FILE_PATH
#$FILE_PATH

config init
	option stdout '1'
	option stderr '1'
	option user 'root'
	option group 'root'
	option respawn '1'

config conf 'common'
	option server_addr '$server_addr'
	option server_port '$server_port'
	option tls_enable 'true'
	option log_level 'trace'
	option token '$token'

config conf 'ssh'
	option type 'tcp'
	option local_ip '$local_ip'
	option local_port '$ssh_local_port'
	option remote_port '$ssh_remote_port'
	option name 'ssh-#$client'

config conf 'web'
	option type 'tcp'
	option local_ip '$local_ip'
	option local_port '$web_local_port'
	option remote_port '$web_remote_port'
	option name 'web-#$client'
EOF

#service frpc restart
