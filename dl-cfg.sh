#!/bin/sh

GIT_URL="https://raw.githubusercontent.com/woodymc/sing-box_cfg/refs/heads/main/"
FILE_LOG_CFG="log.json"
FILE_DNS_CFG="dns.json"
FILE_IN_CFG="inbounds.json"
FILE_ROUTE_CFG="route.json"
FILE_OUT_CFG="outbounds.json"

CFG_DIR="/etc/config/"
SB_CFG_DIR="/etc/sing-box/"
TMP_DIR="/tmp"

CLR_LINE="\x1b[1F\x1b[0K\x1b[1F"

C_RED="\033[31;1m"
C_GRN="\033[32;1m"
C_YEL="\033[33;1m"
C_BLU="\033[34;1m"
C_MGT="\033[35;1m"
C_CYN="\033[36;1m"
C_RST="\033[0m"


check_url_file () {
	if curl -fs $1$2 > /dev/null; then
		curl -Os  $1$3 > $2$3
 		echo 1
	else
 		echo 0
	fi
}

check_file () {
	if [ -f $2$3 ]; then
		while true; do
			read -p "Do you wish to replace '$3' file?" yn
			case $yn in
				[Yy]* )
					if [ $(check_url_file $1 $3) -eq 1 ];	then					
						curl -s  $1$3 > $2$3
						echo -e $CLR_LINE
						printf "$C_GRN""File '$3' will updated.$C_RST\n"
 					fi
					break;;
				[Nn]* )
					echo -e $CLR_LINE
					printf "$C_YEL""File '$3' will not replaced.$C_RST\n"
					break;;
				* )
					printf "$C_RED""Please answer Y or N.$C_RST\n";;
			esac
		done
	else
		if [ $(check_url_file $1 $3) -eq 1 ]; then
			curl -s  $1$3 > $2$3
			printf "$C_GRN""File '$3' will downloaded$C_RST\n"
		else
                        printf "$C_RED""File '$3' not found$C_RST\n"
 		fi
	fi
}

check_file $GIT_URL $CFG_DIR sing-box

check_file $GIT_URL $SB_CFG_DIR $FILE_LOG_CFG 
check_file $GIT_URL $SB_CFG_DIR $FILE_DNS_CFG
check_file $GIT_URL $SB_CFG_DIR $FILE_IN_CFG
check_file $GIT_URL $SB_CFG_DIR $FILE_ROUTE_CFG
check_file $GIT_URL $SB_CFG_DIR $FILE_OUT_CFG

service sing-box restart

printf "______________________________________\n\n"
