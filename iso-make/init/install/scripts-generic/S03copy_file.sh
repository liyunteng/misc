#!/bin/sh

source functions.sh
source conf.sh

dev=$(cat $TARGET_FILE)
if [ ! -b "$dev" ]; then
    echo "Disk $dev not found"
    exit 1;
fi

do_transfer()
{
    # $1: pkg, $2 dir
    pkg=$1
    dir=$2

    echo "Install `basename $dir` ..."

    tar  xf $pkg -C $dir
    if [ $? != 0 ] ;then
        echo "Error: `basename $dir` install failed!"
        exit 1
    fi
}

root_dir="/tmp/root"
parts=`ls $SOURCE/install/*.tgz`
let part_no=5
for part in $parts
do
	mount_dir=`basename $part | awk -F '_' '{ print $1 }'`
	do_transfer $part /tmp/$mount_dir
	
	part_dev=`mount | grep "/tmp/$mount_dir " | awk '{ print $1 }'`
	uuid=`blkid $part_dev | awk -F '"' '{ print $2 }'`
	if [ "$mount_dir" = "root" ]; then
		sed  -ie "s/--set=root .*/--set=root $uuid/" $root_dir/boot/grub/grub.cfg
		sed  -ie "s/UUID=.*ro/UUID=$uuid ro/" $root_dir/boot/grub/grub.cfg
		
		line=`grep -v "^\#" $root_dir/etc/fstab | grep -w "/"`
		echo -n "UUID=$uuid" > $root_dir/etc/fstab.new
		echo $line | awk '{ $1="";print $0 }' >> $root_dir/etc/fstab.new
	else
		line=`grep -v "^\#" $root_dir/etc/fstab | grep -w "$mount_dir"`
		echo -n "UUID=$uuid" >> $root_dir/etc/fstab.new
		echo $line | awk '{ $1="";print $0 }' >> $root_dir/etc/fstab.new
		let part_no+=1
	fi
done

line=`grep -v "^\#" $root_dir/etc/fstab | grep -w "home"`
uuid=`blkid $dev$part_no | awk -F '"' '{ print $2 }'`
echo -n "UUID=$uuid" >> $root_dir/etc/fstab.new
echo $line | awk '{ $1="";print $0 }' >> $root_dir/etc/fstab.new
grep -v "^\#" $root_dir/etc/fstab | grep -v "^UUID" >> $root_dir/etc/fstab.new

cp $root_dir/etc/fstab $root_dir/etc/fstab~
mv $root_dir/etc/fstab.new $root_dir/etc/fstab

exit 0
