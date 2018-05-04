#! /bin/bash

set -ex

host=${1:-1}   # host id, e.g. 1, 2
ifname=${2:-enp0s9}

ip link add vxlan0 type vxlan id 10080 group 239.1.1.1 dev ${ifname}
ip link set vxlan0 address 54:8:10:0:0:$host
ip address add 10.0.0.$host/8 dev vxlan0
ip link set up vxlan0
