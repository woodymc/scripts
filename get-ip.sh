#!/bin/sh
C_RED="\033[31;1m"
C_GRN="\033[32;1m"
C_YEL="\033[33;1m"
C_BLU="\033[34;1m"
C_MGT="\033[35;1m"
C_CYN="\033[36;1m"
C_RST="\033[0m"

printf "\033c" //clear screen
IDENTHOSTS='2ip.ru ifconfig.me showip.net 2ip.io ifconfig.co'
cnt=10
iface="tun0"

HelpShow()	{
	echo ""
	echo "Usage: $0 -f folder -u"
	echo -e "\t-i interface name"
	echo -e "\t-с ping count"
	exit 1 # Exit script after printing help
}

while getopts "i:c:" opt; do
	case "$opt" in
		i ) iface="$OPTARG";;
		c ) cnt="$OPTARG";;
		h ) helpShow;;
		? ) echo "Use -h flag for help."; exit;; # Print case parameter is non-existent
	esac
done

# Check and install opkg programm
CheckProgramm()	{
	if ! $(opkg list-installed | grep -q $1); then
		opkg update --verbosity=0
	 	opkg install $1 --verbosity=0
	fi
}

if [[ -n "$(ip a | grep $iface)" ]]; then
	printf "╔═══════════════════════════════════════════════════════════════════════════════╗\n"
	printf "║			$C_GRN Check route via $C_MGT$iface$C_GRN interface$C_RST\x09\x09\x09\x09║\n"
 	CheckProgramm 'jq'
	printf "║										║\n"
	for host in ${IDENTHOSTS}; do
                ip=$(curl -s --interface $iface $host)
                if [[ -n "$ip" ]]; then
		        resp=$(ping -qc$cnt -w 5 -W 2 $ip)
		        avg=$(echo "$resp" | awk -F'[/=]' 'END{print $6}')
		        loss=$(echo "$resp" | awk '/packet loss/ {print $7}' | tr -d '%')
		        geo=$(curl -s "https://get.geojs.io/v1/ip/cntry.json?ip=$ip" | jq -r ".[0].country")
		        if [ "$loss" == 100 ]; then
		                printf "║ $C_BLU$host$C_RST\x09IP: $C_GRN$geo$C_RST|$ip\x09ping:$C_RED Not response$C_YEL\x09loss: $loss\x25$C_RST\x09║\n"
		        else
		                printf "║ $C_BLU$host$C_RST\x09IP: $C_GRN$geo$C_RST|$ip\x09ping: $avg(AVG)$C_YEL\x09loss: $loss\x25$C_RST\x09║\n"
		        fi
	  	else
    			printf "║ $C_BLU$host$C_RST\x09IP: --|$C_RED NOT RESOLV$C_RST\x09\x09\x09\x09\x09\x09║\n"
       		fi
	done
	printf "║                                                                               ║\n"
	printf "╚═══════════════════════════════════════════════════════════════════════════════╝\n"
else
	printf "╔═══════════════════════════════════════════════════════════════════════════════╗\n"
	printf "║                           interface $C_MGT$iface$C_RST not found				║\n"
	printf "╚═══════════════════════════════════════════════════════════════════════════════╝\n"
fi

