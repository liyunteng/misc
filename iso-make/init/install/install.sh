#!/bin/sh

INSTALL_ROOT=/install
cd $INSTALL_ROOT

source scripts/conf.sh
source scripts/functions.sh
udevd -d 2>/dev/null
trap "" INT

clear
echo "Waiting for device initializing..."
while true
do
	if ls -l /sys/block/sd* | grep -q usb; then
		break;
	fi
	if [ -b /dev/sr0 ]; then
		break;
	fi
	sleep 1
done

# make sure we has ext4 module loaded
modprobe ext4

clear
for script in $(ls ./scripts/S[0-9][0-9]*); do
    RET=0
    if [ -x $script ] ; then
        prog=$(basename $script)
        cd scripts && ./$prog
        if [ "$?" != "0" ]; then
            echo "Install failed: $script"
            RET=1
            break;
        fi
        cd ..
    fi
done

if [ $RET != "0" ]; then
    echo "Failed to install"
    sleep 20
    poweroff
    sleep 10
    exit 1
fi

echo ""
echo "Install OK! Please unplug the USB disk."
read -t 5 -p "Press 'Enter' to reboot(reboot automatically after 5s):" query
reboot

