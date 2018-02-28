#! /bin/bash

# Network ISO source
osurl=http://10.95.31.210/tmp/centos7

# Image name
name=${1:-lms}              # VM name
disk=/opt/vm/$name.qcow2    # Disk path
disk_size=40                # Disk size in GiB
vcpus=4                     # Num of cpu core
mem_size=4096               # RAM size in MiB
ks=ks.cfg                   # Kickstart template file

# Network configure
net1_ip=10.95.30.202        # IP address of first nic, optional
net1_gw=10.95.30.1          # required if net1_ip set
net1_mask=255.255.254.0     # required if net1_ip set
net1_ns=                    # optional

net2_ip=                    # IP address of second nic, optional
net2_gw=                    # optional
net2_mask=255.255.255.0     # required if net2_ip set

set -e

virsh destroy  $name 2>/dev/null || /bin/true
virsh undefine $name 2>/dev/null || /bin/true
rm -f $disk

# Prepare kickstart file
cp $ks /tmp/ks.cfg
if [ -n "$net1_ip" ]; then
    sed -i "s/^network.*/network --device=eth0 --onboot=yes --activate --bootproto=static --ip=${net1_ip} --netmask=${net1_mask} --gateway=${net1_gw} --hostname=${name}/" /tmp/ks.cfg
fi
if [ -n "$net2_ip" ]; then
    opts="network --device=eth1 --onboot=yes --bootproto=static --ip=${net2_ip} --netmask=${net2_mask}"
    [ -n "$net2_gw" ] && opts="$opts --gateway=${net2_gw}"
    sed -i "/^network/a${opts}" /tmp/ks.cfg
fi

# Build VM
set -x
virt-install -n ${name} --ram ${mem_size} --vcpus ${vcpus} --disk path=${disk},format=qcow2,device=disk,bus=virtio,size=${disk_size} --os-type linux --graphics none --network bridge=br0,model=virtio --extra-args="ks=file:ks.cfg console=ttyS0,115200n8" -l $osurl --initrd-inject=/tmp/ks.cfg --noreboot

# Start VM and check its connectivity
set +ex
virsh start ${name}
while true
do
nc ${net1_ip} 22 <<EOF
quit
EOF
[ $? -eq 0 ] && echo "connected" && break
echo -n "." && sleep 1
done

# Copy script and exec installer
sleep 3
scp -o "StrictHostKeyChecking no" -p install.sh root@${net1_ip}:/tmp
ssh -o "StrictHostKeyChecking no" root@${net1_ip} /tmp/install.sh $name
