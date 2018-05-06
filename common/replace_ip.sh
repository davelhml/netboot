#! /bin/bash

mgmr_ip=$(ip addr show dev eth0 | sed -nr 's|.*inet (.*?)/.*|\1|p')
overlay_ip=$(ip addr show dev eth2 | sed -nr 's|.*inet (.*?)/.*|\1|p')

function do_replace_config() {
    dest="$1"
    if [ -f $dest ]; then
        sed -i "s/MANAGEMENT_INTERFACE_IP/${mgmr_ip}/g" $dest
        sed -i "s/OVERLAY_INTERFACE_IP/${overlay_ip}/g" $dest
    fi
}


for i in $@; do
    do_replace_config $i
done
