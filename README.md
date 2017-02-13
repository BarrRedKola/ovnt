# ovnt
Running Transmission dameon in a network namespace on the OpenWRT router
These scripts are doing what the above sentence is tellin' ya!

Usage: sh start.sh 

In case you want to stop everything: sh dismiss_netns_en_masse.sh

-------

Before you start, the followings are required:
 - a custom OpenWRT image, which has the network namespace option enabled in its kernel (usually, default images have no such option, so you need to create/compile your own image)
 - - if you are lucky, you have a TP-LINK WDR3600 as mine, so you can just use my custom image (also located in this repository)
 - Install the following packages on your router (they will fit into WDR3600's memory, if not too many other services are installed)
 - - curl (for getting what's your IP looks like from outside
 - - ip (for namespace stuffs)
 - - socat (for forwarding local access to the network namespace)
 - - transmission-daemon-openssl (transmission daemon itself)
 - - openvpn-openssl (For OpenVPN)
 - Further, but not recommended packages for occasional troubleshooting
 - - tcpdump-mini (tracing packets/monitoring interfaces if something does not work)
 - - nano (just for more comfortable text editing than vi)
 - As indicated in the first lines of create_netns.sh, the firewall needs to be changed to make the network namespace to be able to see the internet. A simple MASQUERADE/SNAT iptables rule is insufficient,
as this little OpenWRT guy has a bit more complicated firewall (as being a router) than your end-host (where the simple iptables rule would work). Fortunately, it is not so difficult, 
just open /etc/config/firewall and look for the 'zone' where your 'lan' is configured. Usually it looks like this:

config zone
	option name 'lan'
	option input 'ACCEPT'
	option output 'ACCEPT'
	option forward 'ACCEPT'
	option network 'lan'

A zone section groups one or more interfaces and serves as a source or destination for forwardings, rules and redirects. Masquerading (NAT) of outgoing traffic is controlled on a per-zone basis.
Add the following lines at the end of zone configuration:
        option device 'veth0 br-lan' 
        option subnet '10.200.1.0/24 192.168.89.0/24'

With the first option, we explicitly add our virtual ethernet pair's first part, which resides in the root namespace. However, this explicit device setup excludes the original br-lan interface set up by
default. Therefore, we need to add 'br-lan' as well. 
The second option is similar to the previous, but for subnets! (under the assumption that br-lan is in the 192.168.89.0/24 range)
DO NOT CHANGE the other IP range and virtual ethernet device name, as the scripts are configuring them in this way!

If further questions arise or you would like to ask me to create a network namespace enabled openwrt image,  just ask here!
