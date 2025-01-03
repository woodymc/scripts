#!/bin/sh
printf "\033c" //clear screen
IDENTHOST='2ip.ru ifconfig.me showip.net 2ip.io'
COUNT=10

printf "╔══════════════════════════════════ \033[32;1mYour IP's\033[0m ══════════════════════════════════╗\n"
printf "║                                                                               ║\n"
for host in ${IDENTHOST}; do
        ip=$(curl -s --interface tun0 $host)
        resp=$(ping -qc$COUNT "$ip")
        avg=$(echo "$resp" | awk -F'[/=]' 'END{print $6}')
        loss=$(echo "$resp" | awk '/packet loss/ {print $7}' | tr -d '%')
        geo=$(curl -s "https://get.geojs.io/v1/ip/country.json?ip=$ip" | jq -r ".[0].country")
        if [ "$loss" == 100 ]; then
                printf "║ \033[34;1m$host\033[0m\x09IP: \033[32;1m$geo\033[0m|$ip\x09ping: \033[31;1mNot response\033[0m\x09\033[33;1mloss: $loss\x25\033[0m\x09║\n"
        else
                printf "║ \033[34;1m$host\033[0m\x09IP: \033[32;1m$geo\033[0m|$ip\x09ping: $avg(AVG)\x09\033[33;1mloss: $loss\x25\033[0m\x09║\n"
        fi
done
printf "║                                                                               ║\n"
printf "╚═══════════════════════════════════════════════════════════════════════════════╝\n"
