#!/bin/sh

source functions.sh
source conf.sh

dev=$(cat $TARGET_FILE)
if [ ! -b "$dev" ]; then
    echo "Disk $dev not found"
    exit 1;
fi

echo "Part $dev ..."
dd if=/dev/zero of=$dev bs=1M count=1 >/dev/null 2>&1

cd $SOURCE/install
root_part_size=`ls *root*.tgz | awk -F '_' '{ print $2 }' | awk -F '.' '{ print $1 }'`
let root_part_size=$root_part_size/8*8

size=`blockdev --getsz $dev`
start=2048
let end=$size/8*8-1

start_root=$start
let end_root=$start_root+$root_part_size-1

let start_extended=$end_root+1
let end_extended=$end

fdisk $dev >/dev/null 2>&1 <<EOF
u
o
n
p
1
${start_root}
${end_root}
n
e
2
${start_extended}
${end_extended}
w
EOF

other_parts=`ls *.tgz | grep -v "root"`
let start=$start_extended+2048
for part in $other_parts
do
	part_size=`echo $part | awk -F '_' '{ print $2 }' | awk -F '.' '{ print $1 }'`
	mount_dir=`echo $part | awk -F '_' '{ print $1 }'`
	let part_size=$part_size/8*8
	let end=$start+part_size-1
	
	fdisk $dev >/dev/null 2>&1 <<EOF
u
n
l
${start}
${end}
w
EOF

	let start=$end+1+2048
done

fdisk $dev >/dev/null 2>&1 <<EOF
u
n
l


w
EOF

let part_no=1
mdev -s
echo "Format ${dev}${part_no} ..."
mkfs.ext4 ${dev}${part_no} >/dev/null 2>&1
if [ $? != 0 ]; then
    echo "Error: Format ${dev}${part_no} failed"
    exit 1
fi

echo "Mount ${dev}${part_no} to /tmp/root ..."
mkdir -p /tmp/root
mount ${dev}${part_no} /tmp/root

let part_no=5
for part in $other_parts
do
	echo "Format ${dev}${part_no} ..."
	mkfs.ext4 ${dev}${part_no} >/dev/null 2>&1
	if [ $? != 0 ]; then
    	echo "Error: Format ${dev}${part_no} failed"
    	exit 1
	fi
	echo "Mount ${dev}${part_no} to /tmp/$mount_dir ..."
	mkdir -p /tmp/$mount_dir
	mount ${dev}${part_no} /tmp/$mount_dir
	let part_no+=1
done

echo "Format ${dev}${part_no} ..."
mkfs.ext4 ${dev}${part_no} >/dev/null 2>&1

exit 0
