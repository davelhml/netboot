#! /bin/bash

source /root/adminrc

openstack network create --external --share --provider-physical-network provider --provider-network-type flat provider1
openstack subnet create --subnet-range 10.95.30.0/23 --gateway 10.95.30.1 --network provider1 --allocation-pool start=10.95.30.100,end=10.95.31.100 --dns-nameserver 8.8.4.4 provider1-v4
openstack network show provider1
openstack subnet list

source /root/demorc

openstack security group rule create --proto icmp default
openstack security group rule create --proto tcp --dst-port 22 default

openstack network create selfservice1
openstack subnet create --subnet-range 192.0.2.0/24 --network selfservice1 --dns-nameserver 8.8.4.4 selfservice1-v4
openstack router create router1
openstack router add subnet router1 selfservice1-v4
neutron router-gateway-set router1 provider1
