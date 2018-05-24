#!/bin/sh

back_dir=init_bak
rm $back_dir -rf
cp -a init $back_dir

cd $back_dir
if [ $? != "0" ]; then
    echo "Can find $back_dir"
    exit 1
fi

while true
do
	echo ""
	echo "Install scripts:"
	ls install | grep -v "install"
	read -p "Choose install scripts: " script_dir
	if [ -d install/$script_dir ]; then
		break
	fi
done

if [ "$script_dir" != "scripts" ]; then
	cp install/$script_dir/* install/scripts/
fi
rm -rf install/scripts-*

find . -name ".git" -exec rm -rf {} \; 2>/dev/null
find . | cpio --quiet -H newc -o | gzip -n > ../initrd.gz
