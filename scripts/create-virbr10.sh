#! /bin/bash

set -ex

mac=$(hexdump -vn3 -e '/3 "52:54:00"' -e '/1 ":%02x"' -e '"\n"' /dev/urandom)


# cleanup
ip link set down dev virbr10 | /bin/true
brctl delbr virbr10 | /bin/true
ip link del virbr10-dummy | /bin/true
if [ -f /var/run/dnsmasq-virbr10.pid ]; then
    kill $(cat /var/run/dnsmasq-virbr10.pid)
fi

sleep 3

ip link add virbr10-dummy address $mac type dummy

# Create a virtual bridge
brctl addbr virbr10
brctl stp virbr10 on
brctl addif virbr10 virbr10-dummy
ip address add 192.168.100.1/24 dev virbr10 broadcast 192.168.100.255
ip link set up virbr10

# SNAT
iptables -t nat -A POSTROUTING -s 192.168.100.0/24 ! -d 192.168.100.0/24 -j MASQUERADE

# DNAT
#iptables -t nat -A PREROUTING -d 10.95.30.13/32 -p tcp -m tcp --syn -m multiport --dports 80,6080,5000,35357 -j DNAT --to-destination 192.168.100.10

# DNSMASQ
mkdir -p /var/lib/dnsmasq/virbr10
touch /var/lib/dnsmasq/virbr10/hostsfile
touch /var/lib/dnsmasq/virbr10/leases
cat > /var/lib/dnsmasq/virbr10/dnsmasq.conf <<EOF
except-interface=lo
interface=virbr10
bind-dynamic
dhcp-range=192.168.100.2,192.168.100.254
dhcp-lease-max=1000
dhcp-leasefile=/var/lib/dnsmasq/virbr10/leases
dhcp-hostsfile=/var/lib/dnsmasq/virbr10/hostsfile
dhcp-no-override
strict-order
EOF
dnsmasq --conf-file=/var/lib/dnsmasq/virbr10/dnsmasq.conf --pid-file=/var/run/dnsmasq-virbr10.pid
