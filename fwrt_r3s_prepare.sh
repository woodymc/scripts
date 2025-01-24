#!/bin/sh
LANGUAGES='ca bg cs de el es fr he hi hu it ja ko mr ms pl pt br ro sk sv tr uk vi cn tw'
printf "\033[33;1m Run prepare FriendlyWRT config for\033[32;1m NanoPi R3S\033[0m\n\n"
opkg update
# remove packages
opkg remove --force-removal-of-dependent-packages aria2 grep collectd-mod-wireless dhcp-forwarder iptables* iwlwifi-firmware-ax200 iwlwifi-firmware-ax210 kmod-br-netfilter kmod-nf-ipt kmod-nf-ipt6 luci-app-ddns luci-app-hd-idle luci-app-minidlna luci-app-samba4 luci-app-upnp luci-proto-3g luci-proto-ipv6 tc-mod-iptables vsftpd wireless-regdb wpad-mini wsdd2 wwan
# remove language pack 'ca bg cs de el es fr he hi hu it ja ko mr ms pl pt br ro sk sv tr uk vi cn tw'
for lang in ${LANGUAGES}; do
        if ! [[ -z $(opkg list-installed | grep '\x2d'$lang' ') ]]; then
                opkg remove $(opkg list-installed | grep '\x2d'$lang' ' | awk -e '{print $1}' | tr '\n' ' ')
        fi
done
# upgrade all installed packages
opkg list-upgradable | cut -f 1 -d ' ' | xargs opkg upgrade
# install new packages
opkg install nano curl jq luci-mod-dashboard
# install system temperature sensors viewer
wget --no-check-certificate -O /tmp/luci-app-temp-status_0.4.1-r1_all.ipk https://github.com/gSpotx2f/packages-openwrt/raw/master/current/luci-app-temp-status_0.4.1-r1_all.ipk
opkg install /tmp/luci-app-temp-status_0.4.1-r1_all.ipk
rm /tmp/luci-app-temp-status_0.4.1-r1_all.ipk
/etc/init.d/rpcd reload
