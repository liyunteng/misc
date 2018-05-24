#!/bin/sh

# 只允许安装在主板原生的sata端口0或1上，并且要保证主板原生的sata端口先被检测到
echo "" >$TARGET_FILE

disk=sda
if ls -l /sys/block/$disk 2>/dev/null | grep -q -w "host[01]"; then
    echo /dev/$disk >$TARGET_FILE

    # check DOM
    if ! check_dom /dev/$disk; then
        break
    fi
    exit 0
fi

echo "Can't find target disk for install"
exit 1
