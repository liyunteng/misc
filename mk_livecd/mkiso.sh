#!/bin/bash
###############################################################################
# Author : liyunteng
# Email : li_yunteng@163.com
# Created Time : 2015-02-05 09:43
# Filename : mkiso.sh
# Description : 
###############################################################################
rm -rf Gentoo.img
/usr/bin/mkisofs -R -J -o Gentoo.img -V Gentoo -b boot/isolinux/isolinux.bin -c boot/isolinux/boot.cat -no-emul-boot -boot-load-size 4 -boot-info-table /media/newroot
/usr/bin/isohybrid Gentoo.img

