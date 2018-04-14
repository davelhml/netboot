#! /bin/bash

virt-addr() {
    VM="$1"
    arp -an | grep "`virsh dumpxml $VM | grep "mac address" | sed "s/.*'\(.*\)'.*/\1/g"`" | awk '{ gsub(/[\(\)]/,"",$2); print $2 }'
}

virt-addr $1
