#! /bin/bash
CONFIGDIR=config
source scripts/common.sh

name=$1
snap=${2:-init}
ini=$CONFIGDIR/$name.ini    # Image config file
[ -z "$name" ] && echo "$0 name image_name [vlan]" && exit 0

image_name=$(__readINI $ini base name)
virsh snapshot-revert --domain ${image_name} --snapshotname ${snap} --force
[ $? -ne 0 ] && exit 1

# Start VM and check its connectivity
virsh start ${image_name}

ip=$(__readINI $ini eth0 ip)

echo -n "Waiting for ${image_name} start"
for i in {1..100}; do
    echo -n '.' && sleep 1
    ping -c 1 -w 1 $ip >/dev/null 2>&1
    [ $? -ne 0 ] && continue
    ssh -i config/devstack -F config/sshconfig root@$ip "echo ok" 2>/dev/null
    [ $? -eq 0 ] && break
done
echo
