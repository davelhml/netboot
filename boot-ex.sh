#! /bin/bash

name=$1
image_name=$2
vlan=$3

[ -z "$name" -o -z "${image_name}" ] && (
    echo "$0 name image_name [vlan]"
) && exit 0

virsh snapshot-revert --domain ${image_name} --snapshotname init --force
[ $? -ne 0 ] && exit 1

# Start VM and check its connectivity
virsh start ${image_name}

# Set Vlan Tag if needed, in subshell
if [ -n "$vlan" ]; then
    ./set-tag-byname.sh ${image_name} $vlan
fi

# Fetch installer and do deploy
./exec-installer.sh $name
