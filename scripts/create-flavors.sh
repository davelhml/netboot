#! /bin/bash

source /root/adminrc

# create flavors
count=$(openstack flavor list -f value -c Name|wc -l)
if [ $count -eq 0 ]; then
    openstack flavor create --id 0 --vcpus 1 --ram 64 --disk 1 m1.nano
    openstack flavor create --id 1 --vcpus 1 --ram 1024 --disk 8 m1.small
    openstack flavor create --id 2 --vcpus 1 --ram 2048 --disk 16 m1.middle
fi
