#!/bin/sh

IP=/usr/bin/ip
NETNS=torrent

echo "Kill transmission"
kill -9 $(ps |grep transmission|grep -v grep|cut -d ' ' -f 1)

echo "Remove socat port forwarding"
kill -9 $(ps |grep socat|grep -v grep|cut -d ' ' -f 1)


echo "Kill VPN process"
kill -9 $(ps |grep openvpn|grep -v grep|cut -d ' ' -f 1)


echo "Delete the whole netns"
$IP netns delete $NETNS
