#!/bin/sh

IPT=/sbin/iptables
# NAT interface
NIF=enp0s9
# NAT IP address
NIP='10.0.99.100'

# Tunnel interface
TIF=enp0s8
# Tunnel ip
TIP='192.168.70.6'

# Host-only interface
HIF=enp0s3
# Host-only IP addres
HIP='192.168.80.100'

# DNS nameserver 
NS='10.0.99.3'

## Reset the firewall to an empty, but friendly state

# Flush all chains in FILTER table
$IPT -t filter -F
# Delete any user-defined chains in FILTER table
$IPT -t filter -X
# Flush all chains in NAT table
$IPT -t nat -F
# Delete any user-defined chains in NAT table
$IPT -t nat -X
# Flush all chains in MANGLE table
$IPT -t mangle -F
# Delete any user-defined chains in MANGLE table
$IPT -t mangle -X
# Flush all chains in RAW table
$IPT -t raw -F
# Delete any user-defined chains in RAW table
$IPT -t mangle -X

# Default policy is to send to a dropping chain
$IPT -t filter -P INPUT DROP
$IPT -t filter -P OUTPUT DROP
$IPT -t filter -P FORWARD DROP


# Forwarding from host-only to tunnel
$IPT -t filter -A FORWARD -i $HIF -o $TIF -j ACCEPT
$IPT -t filter -A FORWARD -i $TIF -o $HIF -j ACCEPT

# Site to Site VPN

$IPT -t filter -A INPUT -i $TIF -p esp -j ACCEPT
$IPT -t filter -A OUTPUT -o $TIF -p esp -j ACCEPT

$IPT -t filter -A INPUT -i $TIF -p udp -m multiport --dports 500,4500 -j ACCEPT
$IPT -t filter -A OUTPUT -o $TIF -p udp -m multiport --sports 500,4500 -j ACCEPT

$IPT -t filter -A FORWARD -i $HIF -j ACCEPT
$IPT -t filter -A FORWARD -i $NIF -m conntrack --ctstate ESTABLISHED,RELATED -j ACCEPT
$IPT -t nat -A POSTROUTING -j SNAT -o $NIF --to $NIP #SNAT



# Create logging chains
#$IPT -t filter -N input_log
#$IPT -t filter -N output_log
#$IPT -t filter -N forward_log

# Set some logging targets for DROPPED packets
#$IPT -t filter -A input_log -j LOG --log-level notice --log-prefix "input drop: " 
#$IPT -t filter -A output_log -j LOG --log-level notice --log-prefix "output drop: " 
#$IPT -t filter -A forward_log -j LOG --log-level notice --log-prefix "forward drop: " 
#echo "Added logging"

# Return from the logging chain to the built-in chain
#$IPT -t filter -A input_log -j RETURN
#$IPT -t filter -A output_log -j RETURN
#$IPT -t filter -A forward_log -j RETURN



# These rules must be inserted at the end of the built-in
# chain to log packets that will be dropped by the default
# DROP policy
#$IPT -t filter -A INPUT -j input_log
#$IPT -t filter -A OUTPUT -j output_log
#$IPT -t filter -A FORWARD -j forward_log
