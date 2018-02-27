#! /bin/bash

set -ex

mac=$(hexdump -vn3 -e '/3 "52:54:00"' -e '/1 ":%02x"' -e '"\n"' /dev/urandom)
ip link add virbr10-dummy address $mac type dummy
ip link show virbr10-dummy

# Create a virtual bridge
brctl addbr virbr10
brctl stp virbr10 on
brctl addif virbr10 virbr10-dummy
ip address add 192.168.100.1/24 dev virbr10 broadcast 192.168.100.255 up

## nat ##
iptables -t nat -A POSTROUTING -s 192.168.100.0/24 -d 224.0.0.0/24 -j RETURN
iptables -t nat -A POSTROUTING -s 192.168.100.0/24 -d 255.255.255.255/32 -j RETURN
# Masquerade all packets going from VMs to the LAN/Internet.
iptables -t nat -A POSTROUTING -s 192.168.100.0/24 ! -d 192.168.100.0/24 -p tcp -j MASQUERADE --to-ports 1024-65535
iptables -t nat -A POSTROUTING -s 192.168.100.0/24 ! -d 192.168.100.0/24 -p udp -j MASQUERADE --to-ports 1024-65535
iptables -t nat -A POSTROUTING -s 192.168.100.0/24 ! -d 192.168.100.0/24 -j MASQUERADE
## filter ##
iptables -A FORWARD -d 192.168.100.0/24 -o virbr10 -m conntrack --ctstate RELATED,ESTABLISHED -j ACCEPT
# Allow outbound traffic from the private subnet.
iptables -A FORWARD -s 192.168.100.0/24 -i virbr10 -j ACCEPT
# Allow traffic between virtual machines.
iptables -A FORWARD -i virbr10 -o virbr10 -j ACCEPT
# Reject everything else.
iptables -A FORWARD -i virbr10 -j REJECT --reject-with icmp-port-unreachable
iptables -A FORWARD -o virbr10 -j REJECT --reject-with icmp-port-unreachable
# Accept DNS (port 53) and DHCP (port 67) packets from VMs.
iptables -A INPUT -i virbr10 -p udp -m udp -m multiport --dports 53,67 -j ACCEPT
iptables -A INPUT -i virbr10 -p tcp -m tcp -m multiport --dports 53,67 -j ACCEPT
## mangle ##
iptables -t mangle -A POSTROUTING -o virbr10 -p udp -m udp --dport 68 -j CHECKSUM --checksum-fill

## DNSMASQ
mkdir -p /var/lib/dnsmasq/virbr10
touch /var/lib/dnsmasq/virbr10/hostsfile
touch /var/lib/dnsmasq/virbr10/leases
/bin/cp -f dnsmasq.conf /var/lib/dnsmasq/virbr10/dnsmasq.conf
dnsmasq --conf-file=/var/lib/dnsmasq/virbr10/dnsmasq.conf --pid-file=/var/run/dnsmasq-virbr10.pid
