#! /bin/bash

name=${1:-lms}              # VM name
disk=/opt/vm/$name.qcow2    # Disk path

virsh destroy  $name 2>/dev/null || /bin/true
virsh undefine $name 2>/dev/null || /bin/true
rm -f $disk
