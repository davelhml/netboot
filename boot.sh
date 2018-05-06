#! /bin/bash

source scripts/common.sh
TEMPDIR=$(mktemp -d /tmp/netboot-XXXX)
CONFIGDIR=config
DELETEOLD=0
if ! options=$(getopt -u -o cd -l cfgdir:, -- "$@")
then
    exit 1
fi
set -- $options
while [ $# -gt 0 ]; do
    case $1 in
        -c|--cfgdir)
            CONFIGDIR=$2
            shift;;
        -d)
            DELETEOLD=1;;
        (--) shift; break;;
        (*)  exit;;
    esac
    shift
done

[ -z "$1" ] && echo "Please specify image type" && exit 1

cat >&1 <<EOF
Deploy "$1":
  Config directory - $CONFIGDIR
  TEMP directory   - $TEMPDIR
EOF
# Image name
name=${1}                   # VM name
ini=$CONFIGDIR/$name.ini    # Image config file
ks=$CONFIGDIR/ks.cfg        # Kickstart template file

set -e
#
osurl=$(__readINI $CONFIGDIR/common.ini common os)        # Network ISO source location
basedir=$(__readINI $CONFIGDIR/common.ini common basedir) # Disk base path
[ -z "$basedir" ] && die "Please specific image basedir"
#
image_name=$(__readINI $ini base name)            # Image Name
vcpus=$(__readINI $ini base vcpus)                # Num of cpu core
mem_size=$(__readINI $ini base ram)               # RAM size in MiB
disk_size=$(__readINI $ini base disk)             # Disk size in GiB

disk_path=${basedir}/${image_name}.qcow2          # Disk path
disk_opts="--disk path=${disk_path},format=qcow2,device=disk,bus=virtio,size=${disk_size}"
extra_opts="ks=file:ks.cfg console=ttyS0,115200n8"

# Prepare kickstart file
tmpks=$TEMPDIR/ks.cfg
/bin/cp -f $ks $tmpks

# Network configure
# eth0: management, eth1: provider, eth2: overlay
network_opts=
ifprev=
for i in {0..2}; do
    iface="eth$i"
    ip=$(__readINI   $ini $iface ip)
    mask=$(__readINI $ini $iface mask)
    gw=$(__readINI   $ini $iface gateway)
    br=$(__readINI   $ini $iface bridge)
    ovs=$(__readINI  $ini $iface ovs)
    vlan=$(__readINI $ini $iface vlan)
    [ -z "$br" ] && break

    echo "Read $iface $ip/$mask/$gw/$br/$ovs/$vlan"

    if [ $i -eq 1 ]; then
        # The provider interface uses a special configuration without an IP address assigned to it
        opts="network --device=$iface --onboot=yes --bootproto=static --noipv4"
    else
        opts="network --device=$iface --onboot=yes --bootproto=static --ip=${ip} --netmask=${mask}"
    fi
    [ -n "$gw" ] && opts="$opts --gateway=${gw}"

    network_opts="${network_opts} --network bridge=${br},model=virtio"
    [ "${ovs}x" == "yesx" ] && network_opts="${network_opts},virtualport_type=openvswitch"

    if [ $i -eq 0 ]; then
        sed -i "s/^network.*/$opts/" $tmpks
        extra_opts="ks=file:ks.cfg console=ttyS0,115200n8 ip=${ip}::${gw}:${mask}:${name}:eth0:none"
    else
        sed -i "/$ifprev/a${opts}" $tmpks
    fi
    ifprev=$iface
done
sed -i "1inetwork --hostname=${name}" $tmpks
set +e
echo "Use ${bootgw} as boot gateway: ${extra_opts}"
echo "VM disk options:    ${disk_opts}"
echo "VM network options: ${network_opts}"

virsh dominfo ${image_name} 2>/dev/null
if [ $? -eq 0 ]; then
    if [ $DELETEOLD -ne 0 ]; then
        ./delete.sh $image_name
    else
        echo "VM already exits, delete it or revert snapshot for re-deploy"
        echo "  ./delete.sh $image_name"
        echo "  ./boot-ex.sh $name $image_name [vlan]"
        exit 0
    fi
fi

set -ex
virt-install -n ${image_name} -r ${mem_size} --vcpus ${vcpus} ${disk_opts} ${network_opts} --os-type linux --graphics none -l $osurl --noreboot --initrd-inject=$tmpks --extra-args "${extra_opts}"
set +ex
echo -n "Take snapshot for ${image_name} and restart"
for i in {0..2}; do
    echo -n "." && sleep 1
done
echo
virsh snapshot-create-as ${image_name} --name init
virsh start ${image_name}
