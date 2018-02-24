#! /bin/bash

iso=$1
[ -z "$iso" ] && echo "Usage $0 isofile" && exit 1

set -ex
mkdir -p /pxeboot

mkdir -p /pxeboot/iso
umount /pxeboot/iso || /bin/true
mount -o loop,rw -t iso9660 $iso /pxeboot/iso

rm -rf /pxeboot/pxelinux
mkdir -p /pxeboot/pxelinux/pxelinux.cfg




cat > /pxeboot/pxelinux/pxelinux.cfg/default <<EOF
prompt 0
default base-image
timeout 3

label base-image
kernel vmlinuz
append initrd=initrd.img ksdevice=eth0 kssendmac ks=http://10.95.30.13:8880/pxelinux/ks.cfg
EOF

/bin/cp ks.cfg /pxeboot/pxelinux
/bin/cp /usr/share/syslinux/pxelinux.0 /pxeboot/pxelinux
/bin/cp /pxeboot/iso/isolinux/{boot.cat,boot.msg,grub.conf,isolinux.bin,splash.png,TRANS.TBL,vesamenu.c32} /pxeboot/pxelinux
/bin/cp /pxeboot/iso/images/pxeboot/{vmlinuz,initrd.img} /pxeboot/pxelinux

# copy nginx config file and restart nginx
/bin/cp -f pxe.conf /etc/nginx/conf.d
nginx -s reload

# copy nginx config file and restart nginx
/bin/cp -f pxeboot.conf /etc/dnsmasq.d/
dnsmasq -d
