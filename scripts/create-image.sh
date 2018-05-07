#! /bin/bash

name=$1
path=$2

if [ -z "$name" -o -z "$path" ]; then
    echo "Usage: $0 <image_name> <image_path>"
    exit 1
fi

source /root/adminrc
openstack image create $name --file $path --disk-format qcow2 --container-format bare --public
