#! /bin/bash

image=${1:-lms}
ksurl=http://10.95.30.13:8880/pxelinux/ks-$image.cfg
osurl=http://10.95.30.13:8880/iso
disk=/tmp/vm/$image.qcow2

set -ex

virsh destroy  xtemplate || /bin/true
virsh undefine xtemplate || /bin/true
mkdir -p /tmp/vm
rm -f $disk

#--extra-args='ks=ftp://192.168.0.43/pub/centos/ks.cfg ksdevice=ens3 ip=192.168.122.90 netmask=255.255.255.0 gateway=192.168.122.1 dns=8.8.8.8' --location=ftp://192.168.0.43/pub/centos

virt-install --name xtemplate --ram 2048 --vcpus 2 --disk path=$disk,format=qcow2,device=disk,bus=virtio,size=40 --os-type linux --graphics vnc,listen=0.0.0.0 --network bridge=br0,model=virtio --noautoconsole --extra-args="ks=$ksurl console=tty0 console=ttyS0,115200n8" --location $osurl
virsh vncdisplay xtemplate
