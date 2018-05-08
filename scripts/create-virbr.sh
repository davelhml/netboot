#! /bin/bash

[ -z "$1" ] && echo "Usage: $0 number" && exit 0

brname=virbr${1}
ifname=${brname}-dummy
net_prefix=192.168.$1

set -ex

mac=$(hexdump -vn3 -e '/3 "52:54:00"' -e '/1 ":%02x"' -e '"\n"' /dev/urandom)

# cleanup
ip link set down dev ${brname} | /bin/true
brctl delbr ${brname} | /bin/true
ip link del ${ifname} | /bin/true
if [ -f /var/run/dnsmasq-${brname}.pid ]; then
    kill $(cat /var/run/dnsmasq-${brname}.pid)
fi

sleep 3

ip link add ${ifname} address $mac type dummy

# Create a virtual bridge
brctl addbr ${brname}
brctl stp ${brname} on
brctl addif ${brname} ${ifname}
ip address add ${net_prefix}.1/24 dev ${brname}
ip link set up ${brname}

# SNAT
iptables -t nat -A POSTROUTING -s ${net_prefix}.0/24 ! -d ${net_prefix}.0/24 -j MASQUERADE

# DNAT
#iptables -t nat -A PREROUTING -d x.x.x.x -p tcp -m tcp --syn -m multiport --dports 80,6080,5000,35357 -j DNAT --to-destination x.x.x.x

# DNSMASQ
mkdir -p /var/lib/dnsmasq/${brname}
touch /var/lib/dnsmasq/${brname}/hostsfile
touch /var/lib/dnsmasq/${brname}/leases
cat > /var/lib/dnsmasq/${brname}/dnsmasq.conf <<EOF
except-interface=lo
interface=${brname}
bind-dynamic
dhcp-range=${net_prefix}.2,${net_prefix}.254
dhcp-lease-max=1000
dhcp-leasefile=/var/lib/dnsmasq/${brname}/leases
dhcp-hostsfile=/var/lib/dnsmasq/${brname}/hostsfile
dhcp-no-override
strict-order
EOF
dnsmasq --conf-file=/var/lib/dnsmasq/${brname}/dnsmasq.conf --pid-file=/var/run/dnsmasq-${brname}.pid
