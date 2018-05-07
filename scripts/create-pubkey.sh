#! /bin/bash

name=$1
path=$2   # ssh private key

if [ -z "$name" -o -z "$path" ]; then
    echo "Usage: $0 <key_name> <key_path>"
    exit 1
fi


ssh-keygen -y -f $path > /tmp/$name.pub
[ $? -ne 0 ] && exit 1

chmod 400 /tmp/$name.pub

source /root/demorc
openstack keypair create $name --public-key /tmp/$name.pub
