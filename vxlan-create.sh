#! /bin/bash

hostid=${1:-1}   # host id, e.g. 1, 2
ifname=${2:-enp0s9}
vxlan_mac=54:8:10:0:0:$hostid
vxlan_ip=10.0.0.$hostid/8

show() {
    ip -d addr show vxlan0
    echo
    ip -d addr show br-vxlan
}

function down() {
    ip link set down dev br-vxlan  | /bin/true
    brctl delbr br-vxlan 2>/dev/null | /bin/true
    ip link del vxlan0  | /bin/true
}

if_up() {
    # Create VXLAN interface, which uses the multicast group 239.1.1.1 over physical device to handle traffic flooding.
    ip link add vxlan0 type vxlan id 10080 group 239.1.1.1 dev ${ifname} ttl 5 dstport 4789
    ip link set vxlan0 address ${vxlan_mac}
    ip link set up vxlan0
}

bridge_up() {
    # Create Vxlan Bridge
    brctl addbr br-vxlan
    brctl addif br-vxlan vxlan0
    brctl stp br-vxlan on
    ip address add ${vxlan_ip} dev br-vxlan  # not necessary
    ip link set up dev br-vxlan
}

case $1 in
    show|down)
        $1;;
    *)
        down
        if_up
        bridge_up
        ;;
esac
