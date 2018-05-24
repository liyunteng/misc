#!/bin/bash -e

if [ ! -x ./geniso.sh ]; then
	echo "no geniso.sh or not executable"
	exit 1
fi

if ! mount -l -t ext3,ext4 | grep -q " /home "; then
	echo "/home is not part mount point."
	exit 1
fi

if ! pwd | grep -q "/home"; then
	echo "This script must run in home part."
	exit 1
fi

if [ "$1" = "" -o "$2" = "" ]; then
	echo "Input prefix and version."
	echo "Usage: auto-package.sh <prefix> <version>"
	exit 1
fi
prefix="$1"
version="$2"

if arch | grep -q "64"; then
	ARCH="64bit"
else
	ARCH="32bit"
fi

pkg_dir=$PWD/package/$ARCH
rm -rf $pkg_dir
mkdir -p $pkg_dir

part_devs=`mount -l -t ext3,ext4 | grep -v " /home " | awk '{ print $1 }'`
mount_dirs=`mount -l -t ext3,ext4 | grep -v home | awk '{ print $3 }'`

find /var/log/ -type f -exec rm -f {} \;
rm -f /etc/udev/rules.d/70-persistent-net.rules
sed -ie "/^For/d" /etc/issue
echo "For $prefix v$version" >> /etc/issue
mv /root/.ssh /tmp
cat << EOF >/usr/local/bin/jw-ssh-keygen
#!/bin/sh
rm -rf /root/.ssh
ssh-keygen -t rsa -N "" -f /root/.ssh/id_rsa
EOF
chmod +x /usr/local/bin/jw-ssh-keygen

let i=1
for part_dev in $part_devs
do
	part_size=`blockdev --getsz $part_dev`
	mount_dir=`echo $mount_dirs | cut -d ' ' -f $i`
	let i+=1

	if [ "$mount_dir" = "/" ]; then
		mount_dir="root"
	else
		mount_dir=`basename $mount_dir`
	fi
	
	rm -rf $mount_dir
	mkdir $mount_dir
	mount $part_dev $mount_dir
	cd $mount_dir
	echo "packaging $mount_dir ..."
	tar cfz $pkg_dir/${mount_dir}_${part_size}.tgz ./ 2>/dev/null || true
	cd ..
	umount $mount_dir
	rm -rf $mount_dir
done

rm -f /usr/local/bin/jw-ssh-keygen
mv /tmp/.ssh /root/

./geniso.sh $prefix $ARCH $version
