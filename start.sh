#!/bin/sh

source config

echo -n "Creating network namespace ${NETNS}"
sh create_netns.sh
check_exit $? "Error occurred during executing create_netns.sh"
sleep 1

echo -n "ConnectingVPN"
sh connect_vpn_netns.sh
check_exit $? "Error occurred during executing connect_vpn_netns.sh"
sleep 1

echo "TRANSMISSION"
sh start_transmission_netns.sh
check_exit $? "Error occurred during executing start_transmission_netns.sh"
