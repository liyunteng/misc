#!/bin/sh

echo "Install grub ..."

dev=$(cat $TARGET_FILE)
if [ ! -b "$dev" ]; then
    echo "Disk $dev not found"
    exit 1;
fi

mkdir -p /tmp/root
mount ${dev}1 /tmp/root >/dev/null 2>71

mount -o bind /dev /tmp/root/dev
mount -t proc proc /tmp/root/proc
chroot /tmp/root /bin/bash <<EOF
grub-install --boot-directory=/boot ${dev} >/dev/null
if [ $? != "0" ]; then
    echo "Error: GRUB install failed"
    exit 1;
fi
exit 0
EOF

if [ $? != "0" ]; then
    exit 1;
fi

exit 0

