#!/bin/bash
###############################################################################
# Author : liyunteng
# Email : li_yunteng@163.com
# Created Time : 2015-02-06 12:00
# Filename : test.sh
# Description : 
###############################################################################
ROOT=
SQUASH_DIR=""
SQUASH="${SQUASH_DIR}squashfs.img"
IMG_DIR="IMG/LiveOS/"
RAMFS="/tmp/ram123"
IMG="${IMG_DIR}/ext3fs.img"
IMG_LABLE="Gentoo-LiveCD"
IMG_UUID="12345678-1234-1234-1234-123456789abc"
set -x
mk_dir()
{
	if [ ! -e "$1" ]; then
		mkdir -p $1
	fi
}
if [ "x$1" = "x" ];then
	echo "$0 root_dir"
	exit 1
fi

ROOT=`dirname $1`/`basename $1`
size=`du -sk $ROOT|awk '{print $1}'`

rm -rf ${IMG} > /dev/null 2>&1
mk_dir ${IMG_DIR}

dd if=/dev/zero of=${IMG} bs=1k count=`echo "$size * 12 / 10"|bc`
mkfs.ext3 -L $IMG_LABLE -U $IMG_UUID $IMG 

mk_dir $RAMFS

if ! findmnt "$RAMFS" > /dev/null;then
	mount -t ext3 $IMG $RAMFS
else
	umount $RAMFS
	mount -t ext3 $IMG $RAMFS
fi

rsync -av $ROOT/ $RAMFS
mk_dir $RAMFS/dev
mk_dir $RAMFS/mnt
mk_dir $RAMFS/media
mk_dir $RAMFS/opt
mk_dir $RAMFS/proc
mk_dir $RAMFS/run
mk_dir $RAMFS/sys
mk_dir $RAMFS/tmp
mk_dir $RAMFS/var
chmod 777 $RAMFS/tmp
umount $RAMFS

chmod 777 $IMG
mk_dir ${SQUASH_DIR}
mksquashfs  `dirname ${IMG_DIR}` ${SQUASH} -noappend -no-fragments -noI -comp xz

