#!/bin/sh

#---- BEFORE START -----#
# TO ENABLE NETWORKING ON OPENWRT FOR THIS NAMESPACE, ADD THESE LINES TO /etc/config/firewall
# to config zone lan
#	option device 'veth0 br-lan' # this lines specifies a device to the zone, we need to add br-lan as well to avoid disconnecting the regular lan from the wan
#	option subnet '10.200.1.0/24 192.168.89.0/24' #first network is the namespace network, and again, we need to add the lan network as well otherwise it becomes overwritten

#=======================#


NETNS=torrent
IP=/usr/bin/ip
VETH0_IP=10.200.1.1
VETH1_IP=10.200.1.2

bring_up_loopback_in_netns ()
{
  #simply bringing up the lo interface in the namespace
  $IP netns exec $NETNS $IP link set dev lo up
}

initialize_veths ()
{
  #create a virtual ethernet pair with name veth0 and veth1
  echo "creating veth pairs..."
  $IP link add veth0 type veth peer name veth1

  #veth1 is being added to the namespace
  echo "Add veth1 to network namespace ${NETNS}"
  $IP link set veth1 netns $NETNS

  #Setting up IP addresses for both of the veth interfaces
  echo "Setting up IP addresses to veths and bringing them up"
  $IP addr add $VETH0_IP/24 dev veth0
  $IP netns exec $NETNS $IP addr add $VETH1_IP/24 dev veth1
  
  #And bringing them up
  $IP link set dev veth0 up
  $IP netns exec $NETNS $IP link set dev veth1 up
  
  echo "[DONE]"

  #Default gateway needs to be set in the namespace to route everything to the
  #other end of the veth pair located in the root namespace
  echo "Add default route to namespace ${NETNS}"
  $IP netns exec $NETNS $IP route add default via $VETH0_IP dev veth1
  echo "[DONE]"
}


add_namespace_to_netns ()
{
  #create namespace specific DNS resolv.conf
  mkdir -p /etc/netns/$NETNS
  #we simply use Google's
  echo "nameserver 8.8.8.8" > /etc/netns/${NETNS}/resolv.conf 
}


#Create namespace
echo "Creating namespace 'torrent'"
$IP netns add $NETNS

echo "List of network namespaces"
$IP netns list

bring_up_loopback_in_netns

initialize_veths


echo "Test pinging..."
$IP netns exec $NETNS ping -c 3 google.com

echo "Restarting firewall to take effect with the new subnets and interfaces"
/etc/init.d/firewall restart


