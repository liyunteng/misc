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

size=`blockdev --getsz $dev`
start=2048
let end=$size/8*8-1

start_root=$start
let end_root=$start_root+$ROOT_SIZE-1

let start_extended=$end_root+1
let end_extended=$end

let start_opt=$start_extended+2048
let end_opt=$start_opt+$OPT_SIZE-1

let start_local=$end_opt+1+2048
let end_local=$start_local+$LOCAL_SIZE-1

let start_left=$end_local+1+2048
let end_left=$end_extended

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
n
l
${start_opt}
${end_opt}
n
l
${start_local}
${end_local}
n
l
${start_left}
${end_left}
w
EOF

mdev -s

mkdir -p /tmp/root
mkdir -p /tmp/opt
mkdir -p /tmp/local

for part_no in 1 5 6 7; do
    part_dev=$dev$part_no
    echo "Format $part_dev ..."
    mkfs.ext4 $part_dev >/dev/null 2>&1
    if [ $? != 0 ]; then
        echo "Error: Format $part_dev failed"
        exit 1
    fi
done

exit 0
