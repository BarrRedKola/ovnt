#!/bin/sh
echo "NS"
sh create_netns.sh
sleep 1

echo "VPN"
sh connect_vpn_netns.sh
sleep 1

echo "TRANSMISSION"
sh start_transmission_netns.sh
