#! /bin/bash

virsh domiflist ${1}

for vnet in $(virsh domiflist ${1} |egrep -o 'vnet[0-9]+')
do
    ovs-vsctl show |grep -C2 "$vnet\b"
done
