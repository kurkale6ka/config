#!/bin/busybox sh

rescue_shell() {
   echo "$@" >&2
   busybox --install -s
   exec /bin/sh
}

# most of code coming from /etc/init.d/fsck
check_filesystem() {

    local fsck_opts= check_extra= RC_UNAME=$(uname -s)

    # FIXME : get_bootparam forcefsck
    if [[ -e /forcefsck ]]; then
        fsck_opts="$fsck_opts -f"
        check_extra='(check forced)'
    fi

    echo "Checking local filesystem $check_extra : $1"

    if [[ $RC_UNAME = Linux ]]; then
        fsck_opts="$fsck_opts -C0 -T"
    fi

    trap : INT QUIT

    # using our own fsck, not the builtin one from busybox
    /sbin/fsck -p $fsck_opts $1

    case $? in
         0)     return 0;;
         1)     echo 'Filesystem repaired'; return 0;;
       2|3)     if [[ $RC_UNAME = Linux ]]; then
                   echo 'Filesystem repaired, but reboot needed'
                   reboot -f
                else
                   rescue_shell 'Filesystem still have errors; manual fsck required'
                fi;;
         4)     if [[ $RC_UNAME = Linux ]]; then
                   rescue_shell 'Fileystem errors left uncorrected, aborting'
                else
                   echo 'Filesystem repaired, but reboot needed'
                   reboot
                fi;;
         8)     echo 'Operational error'            >&2; return 0;;
        12)     echo 'fsck interrupted'             >&2          ;;
         *)     echo "Filesystem couldn't be fixed" >&2          ;;
    esac
    rescue_shell 'Something went wrong. Dropping you to a shell.'
}

# Mount the /proc and /sys filesystems.
mount -t proc none /proc
mount -t sysfs none /sys
mount -t devtmpfs none /dev # needed by lvm (else: dev nodes missing)

# Do your stuff here.
echo 'This script mounts rootfs and usr, boots rootfs up and nothing more!'
echo '--------------------------------------------------------------------'

# Mount the root filesystem.
mount -o ro /dev/sda3 /mnt/root || rescue_shell 'Unable to mount the root filesystem.'

lvm vgscan --mknodes
lvm lvchange -aly vg/usr

mount -o noatime /dev/mapper/vg-usr /mnt/root/usr || rescue_shell 'Unable to mount the usr logical volume.'

# Clean up.
umount /proc
umount /sys
umount /dev

# Boot the real thing.
echo 'Booting'
echo '--------------------------------------------------------------------'
exec switch_root /mnt/root /sbin/init
