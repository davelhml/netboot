#! /bin/bash

name=$1
image=${2:-cirros}
flavor=${3:-m1.nano}

[ -z "$name" ] && echo "Usage: $0 name [image] [flvor]"

source /root/demorc

net_id=$(openstack network show selfservice1 -f value -c id)

echo -n "Create VM..."
openstack server create --flavor ${flavor} --image ${image} --nic net-id=${net_id} ${name}
echo
echo -n "Wait for VM active"

vm_status=$(openstack server show ${name} -f value -c status)
vm_status=${vm_status,,}
while [ "$vm_status" != 'active' ]
do
    echo -n ". (status:${vm_status})" && sleep 1
    vm_status=$(openstack server show ${name} -f value -c status)
    vm_status=${vm_status,,}
done
echo
echo
#openstack floating ip create provider1
#openstack server add floating ip selfservice-instance1 ${flouting_ip}
