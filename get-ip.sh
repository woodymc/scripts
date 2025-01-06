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

read -t 8 -p "Enter checked interface (timeout in 8 seconds):" riface

if [[ -n "$riface" ]]; then
	iface=$riface
else
	printf "\nChecking default interface tun0\n"
fi

if [[ -n "$(ip a | grep $iface)" ]]; then
	printf "╔═════════════════════════════════ $COLOR_GREENCheck route$COLOR_RESET ═════════════════════════════════╗\n"
	printf "║                                    $COLOR_GREENvia $COLOR_MAGENTA$iface$COLOR_RESET                           	║\n"
	for host in ${IDENTHOST}; do
                ip=$(curl -s --interface $iface $host)
                if [[ -n "$ip" ]]; then
		        resp=$(ping -qc$COUNT $ip)
		        avg=$(echo "$resp" | awk -F'[/=]' 'END{print $6}')
		        loss=$(echo "$resp" | awk '/packet loss/ {print $7}' | tr -d '%')
		        geo=$(curl -s "https://get.geojs.io/v1/ip/country.json?ip=$ip" | jq -r ".[0].country")
		        if [ "$loss" == 100 ]; then
		                printf "║ \033[34;1m$host\033[0m\x09IP: \033[32;1m$geo\033[0m|$ip\x09ping: \033[31;1mNot response\033[0m\x09\033[33;1mloss: $loss\x25\033[0m\x09║\n"
		        else
		                printf "║ \033[34;1m$host\033[0m\x09IP: \033[32;1m$geo\033[0m|$ip\x09ping: $avg(AVG)\x09\033[33;1mloss: $loss\x25\033[0m\x09║\n"
		        fi
	  	else
    			printf "║ \033[34;1m$host\033[0m\x09IP: XX|\033[31;1mNOT RESOLV\033[31;1m\033[0m\x09\x09\x09\x09\x09\x09║\n"
       		fi
	done
	printf "║                                                                               ║\n"
	printf "╚═══════════════════════════════════════════════════════════════════════════════╝\n"
else
	printf "╔═══════════════════════════════════════════════════════════════════════════════╗\n"
	printf "║                           interface $iface not found				║\n"
	printf "╚═══════════════════════════════════════════════════════════════════════════════╝\n"
fi

