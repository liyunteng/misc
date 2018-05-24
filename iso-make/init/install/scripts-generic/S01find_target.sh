#!/bin/sh

# 安装硬raid卡后，会先检测到硬raid，后检测到主板原生的sata端口，所以只能通过磁盘大小来判断
echo "" >$TARGET_FILE

found="no"
disks=`ls /sys/block | grep sd` 2>/dev/null
for disk in $disks
do
	size=`cat /sys/block/$disk/size`
	if [ $size -gt 12000000 -a $size -lt 630000000 ]; then
		found="yes"
		break
	fi
done

if [ "$found" != "yes" ]; then
	echo "Can't find target disk for install"
	exit 1
fi

echo /dev/$disk >$TARGET_FILE

# check DOM
check_dom /dev/$disk
