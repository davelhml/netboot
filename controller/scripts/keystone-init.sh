#! /bin/bash

# Create a domain, projects, users, and roles
source /root/adminrc

openstack domain create --description "An Example Domain" example
openstack project create --domain default --description "Service Project" service
openstack project create --domain default --description "Demo Project" demo
openstack user create --domain default --password cc demo
openstack role create user
openstack role add --project demo --user demo user
