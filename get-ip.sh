#!/bin/sh
printf "\033c" //clear screen
IDENTHOST='2ip.ru ifconfig.me showip.net 2ip.io'
COUNT=10

printf "╔══════════════════════════════════ \033[32;1mYour IP's\033[0m ══════════════════════════════════╗\n"
printf "║                                                                               ║\n"
for host in ${IDENTHOST}; do
        ip="$(curl -s --interface tun0 $host)"
        resp=$(ping -qc$COUNT "$ip")
        avg=$(echo "$resp" | awk -F'[/=]' 'END{print $6}')
        loss=$(echo "$resp" | awk '/packet loss/ {print $7}' | tr -d '%')
        if [ "$loss" == 100 ]; then
                        printf "║ $host IP: $ip ping: Not response      loss: $loss\x25 ║\n"
        else
            printf "║ $host     IP: $ip ping: $avg(AVG) loss: $loss\x25 ║\n"
        fi
done
printf "║                                                                               ║\n"
printf "╚═══════════════════════════════════════════════════════════════════════════════╝\n"
