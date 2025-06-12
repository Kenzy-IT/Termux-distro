#!/bin/sh

# Path of FEDORA rootfs
DEBIANPATH="/data/local/tmp/chrootFedora"

# Fix setuid issue
busybox mount -o remount,dev,suid /data

busybox mount --bind /dev $DEBIANPATH/dev
busybox mount --bind /sys $DEBIANPATH/sys
busybox mount --bind /proc $DEBIANPATH/proc
busybox mount -t devpts devpts $DEBIANPATH/dev/pts

# /dev/shm for Electron apps
mkdir -p $DEBIANPATH/dev/shm
busybox mount -t tmpfs -o size=256M tmpfs $DEBIANPATH/dev/shm

# Mount sdcard
mkdir -p $DEBIANPATH/sdcard
busybox mount --bind /sdcard $DEBIANPATH/sdcard

# chroot into FEDORA and launch XFCE4 as fedora user
busybox chroot $DEBIANPATH /bin/su - fedora -c 'export DISPLAY=:0 && export PULSE_SERVER=127.0.0.1 && dbus-launch --exit-with-session startxfce4'