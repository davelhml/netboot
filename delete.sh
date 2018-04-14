#! /bin/bash




function delete_vm() {
    name=${1}

    for sn in $(virsh snapshot-list $name --name)
    do
        if [ -n "$sn" ]; then
            virsh snapshot-delete $name --snapshotname $sn --children
        fi
    done

    virsh domblklist $name --details
    virsh domblklist $name --details | \
        while read line; do
          blk_type=$(echo $line|awk '{ print $1 }')
          blk_device=$(echo $line|awk '{ print $2 }')
          blk_path=$(echo $line|awk '{ print $4 }')

          if [ "${blk_type}x" == "filex" -a "${blk_device}x" == "diskx" ]; then
              echo rm -f ${blk_path}
              rm -f ${blk_path}
          fi
        done

    virsh destroy  $name 2>/dev/null || /bin/true
    virsh undefine $name 2>/dev/null || /bin/true
}

for i in $@
do
    delete_vm $i
done
