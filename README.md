# ovnt 
Running Transmission dameon in a network namespace on the OpenWRT router.

OVNT = Openwrt+Vpn+Network namespace+Transmission-daemon


Usage:

    # sh start.sh 

In case you want to stop everything: 

    # sh dismiss_netns_en_masse.sh

-------
# IMPORTANT!
Before you start, the followings are required:
 - a custom OpenWRT image, which has the network namespace option enabled in its kernel (usually, default images have no such option, so you need to create/compile your own image)
   - if you are lucky, you have a TP-LINK WDR3600 as mine, so you can just use my custom image (also located in this repository)
 - For VPN, I used nordVPN service, and I store a randomly selected configuration file (nl15.nordvpn.com.udp1194.ovpn) in /mnt/data/nordVPN. Change this settings in connect_vpn_netns.sh 
if needed.
 - OpenVPN may asks for username and password, which would stop the whole process at the most important checkpoint!
In order to avoid asking for your credentials, open the corresponding .ovpn file and look for:

    auth-user-pass

Create a text file called auth.txt, where the first line is your username, whilst the second is your password. And nothing more, do not put any other things and/or comments into this file. Place this file next to the .ovpn file and change the above-mentioned line as follows:

    auth-user-pass auth.txt


 - Install the following packages on your router (they will fit into WDR3600's memory, if not too many other services are installed. I have all the followings with additional ddns,printing, 
and samba service and still have more than 1M)
   - curl (for using web-based service to check what's your IP looks like from outside)
   - ip (for namespace stuffs)
   - socat (for forwarding local access to the network namespace)
   - transmission-daemon-openssl (transmission daemon itself) - After installing transmission, it becomes enabled by default,
   which means OpenWRT will starts it whenever it has been rebooted! We need to avoid this, as it would not start transmission
   in the namespace (however, one may can hack those parts of the system as well). In order to achieve this, the easiest way is
   to go to Luci->System->Startup and look for transmission. Once found, click on the Enabled button to disable it.
   - openvpn-openssl (For OpenVPN)
 - Further, but not recommended packages for occasional troubleshooting
   - tcpdump-mini (tracing packets/monitoring interfaces if something does not work)
   - nano (just for more comfortable text editing than vi)
 - As indicated in the first lines of create_netns.sh, the firewall needs to be changed to make the network namespace to be able to see the internet. A simple MASQUERADE/SNAT iptables rule is insufficient,
as this little OpenWRT guy has a bit more complicated firewall (as being a router) than your end-host (where the simple iptables rule would work) would have. Fortunately, it is not that difficult, 
just open /etc/config/firewall and look for the 'zone' configuration where your 'lan' is defined. Usually it looks like this:


        config zone
        option name 'lan
        option input 'ACCEPT'
        option output 'ACCEPT'
        option forward 'ACCEPT'
        option network 'lan'

A zone section groups one or more interfaces and serves as a source or destination for forwardings, rules and redirects. Masquerading (NAT) of outgoing traffic is controlled on a per-zone basis. OpenWRT's firewall creates NAT between zones 'lan' and the 'wan' (as can be seen in /etc/config/firewall as well). If we do not want to create new zones and special rules, we just need to add our namespace-related interfaces to 'lan' zone, and everything shall be working then.
Thus, add the following lines at the end of zone 'lan' configuration:

    option device 'veth0 br-lan' 
    option subnet '10.200.1.0/24 192.168.89.0/24'

With the first option, we explicitly add our virtual ethernet pair's first part (veth0) to the zone, which resides in the root namespace. However, this explicit device setup excludes the original br-lan interface set up by
default. Therefore, we need to add 'br-lan' back as well. 
The second option is similar to the previous, but for subnets! (under the assumption that 'br-lan' is in the '192.168.89.0/24' range)


DO NOT CHANGE the other subnet (10.200.1.0/24) and virtual ethernet device name (veth0), as the scripts configure them in this way!

After everything went fine, add the checkMyTorrentIp.png.torrent file (can be found in this repo as well) to your transmission-daemon and look for the tracker status! It shall also  print out the IP address of your VPN enabled network namespace. 

-------
If you want your OpenWRT system to do the whole thing automatically after every boot, just add
    
    sh start.sh
to the Local startup scripts (Luci->System->Startup)

If further questions arise or you would like to ask me to create a network namespace enabled openwrt image,  just ask here!
