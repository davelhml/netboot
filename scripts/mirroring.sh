#! /bin/bash

# veth - Virtual Ethernet Device
# http://man7.org/linux/man-pages/man4/veth.4.html

ovs-vsctl clear Bridge br-int mirrors
ovs-vsctl --if-exists del-port br-int mirror0

ip link del mirror0
ip link add mirror0 type veth peer name mirror1
ip link set mirror0 up
ip link set mirror1 up


ovs-vsctl add-port br-int mirror0
echo
echo List ports on br-int:
ovs-vsctl list-ports br-int

#ifname="qg-da1af6c3-97"
#ifname="qr-746ec51e-92"
ifname="int-br-provider"
echo
echo Create the mirror and mirror the packet from $ifname:

ovs-vsctl -- set Bridge br-int mirrors=@m \
    -- --id=@"$ifname" get Port "$ifname" \
    -- --id=@mirror0 get Port mirror0 \
    -- --id=@m create Mirror name=mymirror select-dst-port=@"$ifname" select-src-port=@"$ifname" output-port=@mirror0
#   -- --id=@br-int get Port br-int \
#   -- --id=@m create Mirror name=mymirror select-dst-port=@patch-tun,@br-int select-src-port=@patch-tun,@br-int output-port=@mirror0

echo
cat >&1 <<EOF
Now type "tcpdump -ee -nn -i mirror0" or "tcpdump -ee -nn -i mirror1" to dump mirrored traffic
EOF


