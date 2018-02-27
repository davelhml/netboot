#! /bin/bash

iso=$1
[ -z "$iso" ] && echo "Usage $0 isofile" && exit 1

set -ex

mkdir -p /pxeboot/iso
umount /pxeboot/iso || /bin/true
mount -o loop,rw -t iso9660 $iso /pxeboot/iso

rm -rf /pxeboot/pxelinux
mkdir -p /pxeboot/pxelinux/pxelinux.cfg

/bin/cp *.cfg /pxeboot/pxelinux

# copy nginx config file and restart nginx
/bin/cp -f pxe.conf /etc/nginx/conf.d
nginx -s reload

# Config PXE
# copy nginx config file and restart nginx
#/bin/cp /usr/share/syslinux/pxelinux.0 /pxeboot/pxelinux
#/bin/cp /pxeboot/iso/isolinux/{boot.cat,boot.msg,grub.conf,isolinux.bin,splash.png,TRANS.TBL,vesamenu.c32} /pxeboot/pxelinux
#/bin/cp /pxeboot/iso/images/pxeboot/{vmlinuz,initrd.img} /pxeboot/pxelinux
#cat > /pxeboot/pxelinux/pxelinux.cfg/default <<EOF
#prompt 0
#default base-image
#timeout 3

#label base-image
#kernel vmlinuz
#append initrd=initrd.img ksdevice=eth0 kssendmac ks=http://10.95.30.13:8880/pxelinux/ks.cfg
#EOF

#/bin/cp -f dnsmasq.conf /var/lib/dnsmasq/virbr10/dnsmasq.conf
#kill $(cat /var/run/dnsmasq-virbr10.pid) || /bin/true
#dnsmasq -d --conf-file=/var/lib/dnsmasq/virbr10/dnsmasq.conf --pid-file=/var/run/dnsmasq-virbr10.pid
