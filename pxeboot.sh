#! /bin/bash

set -ex

virsh destroy xtemplate || /bin/true
virsh undefine xtemplate  || /bin/true
rm -f /tmp/centos73.qcow2
virt-install --pxe --name xtemplate --ram 2048 --vcpus 2 --disk path=/tmp/centos73.qcow2,format=qcow2,device=disk,bus=virtio,size=10 --os-type linux --graphics vnc,listen=0.0.0.0 --noautoconsole --network bridge=br0,model=virtio
virsh vncdisplay xtemplate
