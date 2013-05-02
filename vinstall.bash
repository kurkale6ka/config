#! /usr/bin/env bash

# virt-install --os-variant list

name="$1"
image=/var/lib/libvirt/images/"$name".img
size=7 # in Gigabytes
# The location must be the root directory of an install tree
mirror=http://mirror.as29550.net/mirror.centos.org/6.4/os/x86_64/

ksdir=/var/lib/libvirt/images
ks=centos.ks

# http://fedoraproject.org/wiki/Anaconda/Kickstart
if [[ ! -f $ksdir/$ks ]]; then
cat << 'EOF' > "$ksdir"/"$ks"
install
text
reboot
lang en_GB.UTF-8
keyboard uk
network --bootproto dhcp
rootpw password
firewall --disabled
selinux --disabled
timezone --utc Europe/London
bootloader --location=mbr --append="console=tty0 console=ttyS0,115200 rd_NO_PLYMOUTH"
zerombr
clearpart --all --initlabel
autopart

%packages
@core
%end
EOF
fi

qemu-img create "$image" "$size"G
chown qemu.qemu "$image"

virt-install                                                 \
--connect=qemu:///system                                     \
--initrd-inject="$ksdir"/"$ks"                               \
--extra-args="ks=file:$ks console=tty0 console=ttyS0,115200" \
--name "$name"                                               \
--ram 1024                                                   \
--vcpus=4                                                    \
--os-type=linux                                              \
--os-variant=rhel6                                           \
--accelerate                                                 \
--hvm                                                        \
--location="$mirror"                                         \
--network bridge=br0                                         \
--graphics none                                              \
--disk path="$image",size="$size"

# Note:
#    if using --graphics vnc, you can monitor the progress of your install with
#    a VNC client (use netstat -nltp to get the port (eg: localhost:5900))

# After reboot steps:
#    passwd
#    hostame <vm>
#    useradd <user>
#    passwd <user>
#    visudo (uncomment %wheel)
#    gpasswd -a <user> wheel
#    ifconfig (to see IP)
#    add <vm> to ~/.ssh/config
#    ssh-copy-id <vm>
