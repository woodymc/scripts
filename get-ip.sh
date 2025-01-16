#!/bin/sh
COLOR_RED="\033[31;1m"
COLOR_GREEN="\033[32;1m"
COLOR_YELLOW="\033[33;1m"
COLOR_BLUE="\033[34;1m"
COLOR_MAGENTA="\033[35;1m"
COLOR_CYAN="\033[36;1m"
COLOR_RESET="\033[0m"

printf "\033c" //clear screen
IDENTHOST='2ip.ru ifconfig.me showip.net 2ip.io'
COUNT=10
iface="tun0"

#read -t 8 -p "Enter checked interface (timeout in 8 seconds):" riface

if [[ -n "$1" ]]; then
	iface=$1
fi

if ! $(opkg list-installed | grep -q jq); then
#	printf "###jq NOT installed";
	opkg update --verbosity=0
 	opkg install jq --verbosity=0
fi


if [[ -n "$(ip a | grep $iface)" ]]; then
	printf "╔═══════════════════════════════════════════════════════════════════════════════╗\n"
	printf "║			$COLOR_GREEN Check route via $COLOR_MAGENTA$iface$COLOR_GREEN interface$COLOR_RESET\x09\x09\x09\x09║\n"
	printf "║										║\n"
	for host in ${IDENTHOST}; do
                ip=$(curl -s --interface $iface $host)
                if [[ -n "$ip" ]]; then
		        resp=$(ping -qc$COUNT $ip)
		        avg=$(echo "$resp" | awk -F'[/=]' 'END{print $6}')
		        loss=$(echo "$resp" | awk '/packet loss/ {print $7}' | tr -d '%')
		        geo=$(curl -s "https://get.geojs.io/v1/ip/country.json?ip=$ip" | jq -r ".[0].country")
		        if [ "$loss" == 100 ]; then
		                printf "║ $COLOR_BLUE$host$COLOR_RESET\x09IP: $COLOR_GREEN$geo$COLOR_RESET|$ip\x09ping:$COLOR_RED Not response$COLOR_YELLOW\x09loss: $loss\x25$COLOR_RESET\x09║\n"
		        else
		                printf "║ $COLOR_BLUE$host$COLOR_RESET\x09IP: $COLOR_GREEN$geo$COLOR_RESET|$ip\x09ping: $avg(AVG)$COLOR_YELLOW\x09loss: $loss\x25$COLOR_RESET\x09║\n"
		        fi
	  	else
    			printf "║ $COLOR_BLUE$host$COLOR_RESET\x09IP: XX|$COLOR_RED NOT RESOLV$COLOR_RESET\x09\x09\x09\x09\x09\x09║\n"
       		fi
	done
	printf "║                                                                               ║\n"
	printf "╚═══════════════════════════════════════════════════════════════════════════════╝\n"
else
	printf "╔═══════════════════════════════════════════════════════════════════════════════╗\n"
	printf "║                           interface $COLOR_MAGENTA$iface$COLOR_RESET not found				║\n"
	printf "╚═══════════════════════════════════════════════════════════════════════════════╝\n"
fi

