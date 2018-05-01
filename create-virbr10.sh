#! /bin/bash

set -ex

mac=$(hexdump -vn3 -e '/3 "52:54:00"' -e '/1 ":%02x"' -e '"\n"' /dev/urandom)
ip link add virbr10-dummy address $mac type dummy
ip link show virbr10-dummy

# Create a virtual bridge
brctl addbr virbr10
brctl stp virbr10 on
brctl addif virbr10 virbr10-dummy
ip address add 192.168.100.1/24 dev virbr10 broadcast 192.168.100.255
ifconfig virbr10 up

## nat ##
iptables -t nat -A POSTROUTING -s 192.168.100.0/24 ! -d 192.168.100.0/24 -j MASQUERADE

## DNSMASQ
mkdir -p /var/lib/dnsmasq/virbr10
touch /var/lib/dnsmasq/virbr10/hostsfile
touch /var/lib/dnsmasq/virbr10/leases
/bin/cp -f dnsmasq.conf /var/lib/dnsmasq/virbr10/dnsmasq.conf
dnsmasq --conf-file=/var/lib/dnsmasq/virbr10/dnsmasq.conf --pid-file=/var/run/dnsmasq-virbr10.pid
