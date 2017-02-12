#!/bin/sh

NETNS=torrent
IP=/usr/bin/ip
VETH0_IP=10.200.1.1
VETH1_IP=10.200.1.2


#ipecho.net/plain is a good stuff to check which IP is used to connect to the internet
echo "Currently the netns shows himself from this IP"
$IP netns exec $NETNS curl http://ipecho.net/plain;echo


#Here, we assume you use nordVPN and your openVPN config files are located on a mounted
#pendrive at /mnt/data/nordVPN
VPN_ROOT=/mnt/data/nordVPN
VPN_FILE=nl15.nordvpn.com.udp1194.ovpn

cd $VPN_ROOT

#Establishing connection to your VPN service
echo "Enabling openVPN in netns ${NETNS}"
$IP netns exec $NETNS openvpn --daemon --config $VPN_FILE
echo 


#here, we look after the tun0 interface in the network namespace
#until it is not up and running, we don't process
echo "Waiting the VPN connectivity became established..."
retval=1
while [ $retval -gt 0 ] 
do
  echo -n "/\.-."
  #now, we see after the tun0 interface, which when came up return status ($?) will be 0, instead of 1
  retval=$($IP netns exec $NETNS ifconfig|grep tun0 > /dev/null;echo $?)
  sleep 1
done
echo

#now, we check again our IP
echo "Currently the netns shows himself from this IP"
$IP netns exec $NETNS curl http://ipecho.net/plain;echo

echo
echo "Does it differ from the previous one? Double-check!"
echo "If YES! U're good to go ;)"
echo
