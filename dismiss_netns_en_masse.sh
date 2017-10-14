#!/bin/sh

IP=/usr/bin/ip
NETNS=torrent

echo "Kill all possible transmission processes"
for i in $(ps |grep transmission|grep -v 'grep transmission'|awk '{print $1}')
do
  kill -9 $i
done
echo "Remove all possible socat port forwarding"
for i in $(ps |grep "socat tcp-listen:9091,reuseaddr,fork tcp-connect:10.200.1.2:9091"|grep -v 'grep socat'|awk '{print $1}')
do
  kill -9 $i
done

#get the used vpn_service
vpn_service=$(cat last_best_server)
echo "Kill all possible VPN processes for the given VPN service ${vpn_service}"
for i in $(ps |grep openvpn | grep "${vpn_service}"|grep -v 'grep'|awk '{print $1}')
do
  kill -9 $i
done

echo "Delete the whole netns"
$IP netns delete $NETNS
