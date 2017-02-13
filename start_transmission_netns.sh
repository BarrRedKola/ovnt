#!/bin/sh

source config 

#start transmission in the network namespace
#NEVER use /etc/transmission/start, as it would start in the root namespace
echo "Starting transmission in netns ${NETNS}"
$IP netns exec $NETNS /usr/bin/transmission-daemon -g /etc/transmission -f &


#Now, we need to access somehow the transmission daemon running in the namespace from outside
#With socat, we create a socket that listens on port 9091 in the root namespace and forwards traffic
#to the namespace's same port (where the practical transmission daemon is listening
#the 'fork' is needed in socat to avoid termination of the whole socket once a connection has been established
echo
echo "Create a socket on the root namespace that redirects RPC access on veth0 to the namespace's veth1"
socat tcp-listen:9091,reuseaddr,fork tcp-connect:10.200.1.2:9091 &

echo "[DONE]"
echo 
