#!/bin/sh

source functions.sh
source conf.sh

dev=$(cat $TARGET_FILE)
if [ ! -b "$dev" ]; then
    echo "Disk $dev not found"
    exit 1;
fi

ROOT=$ROOT_DIR
OPT=$OPT_DIR
LOCAL=$LOCAL_DIR
tar_dir=$SOURCE/install

mkdir -p $ROOT
mkdir -p $OPT
mkdir -p $LOCAL

do_transfer()
{
    # $1: name, $2 dev, $3 dir, $4 tar
    name=$1
    part=$2
    dir=$3
    pkg=$4

    echo "Install $name part ..."
    if ! mount $part $dir; then
        echo "Error: mount $name failed"
        exit 1
    fi

    tar  xf $pkg -C $dir
    if [ $? != 0 ] ;then
        echo "Error: $name files install failed!"
        exit 1
    fi
    if ! verify_pkg $dir; then
        echo "Error: $name files verify failed!"
        exit 1
    fi
    umount $dir
}

eval `awk -F '#' '{ print $1 }' $ROOT_DEV/install.conf 2>/dev/null | tr -d ' '`
if [ "$sw_type" != "BASIC-PLATFORM" -a "$sw_type" != "IPSAN-NAS" ]; then
    while true
    do
        echo ""
        echo "Please choose software type"
        echo " 1 BASIC-PLATFORM"
        echo " 2 IPSAN-NAS"
        read -p "Enter the software number: " sw_no
        if [ "x$sw_no" = "x1" -o "x$sw_no" = "x2" ]; then
            break
        fi
    done
    
    if [ "x$sw_no" = "x1" ]; then
        sw_type="BASIC-PLATFORM"
    elif [ "x$sw_no" = "x2" ]; then
        sw_type="IPSAN-NAS"
    fi
fi

product_name=`dmidecode -s baseboard-product-name 2>/dev/null`
if [ "$product_name" = "$SYS_6026B_T" ]; then
	hw_type="2U8-STANDARD"
elif  [ "$product_name" = "$SYS_6026N_T" ]; then
	hw_type="2U8-ATOM"
elif  [ "$product_name" = "$SYS_6036B_T" ]; then
	hw_type="3U16-SIMPLE"
elif  [ "$product_name" = "$SYS_6036C_T" -o "$product_name" = "$SYS_6036Z_T" ]; then
	hw_type="3U16-STANDARD"
else
	if [ "$hw_type" != "3U16-STANDARD" -a "$hw_type" != "3U16-SIMPLE" -a \
	        "$hw_type" != "2U8-STANDARD" -a "$hw_type" != "2U8-ATOM" ]; then
	    while true
	    do
	        echo ""
	        echo "Please choose hardware type"
	        echo " 1 3U16-STANDARD"
	        echo " 2 3U16-SIMPLE"
	        echo " 3 2U8-STANDARD"
	        echo " 4 2U8-ATOM"
	        read -p "Enter the hardware number: " hw_no
	        if [ "x$hw_no" = "x1" -o "x$hw_no" = "x2" -o "x$hw_no" = "x3" -o \
	                "x$hw_no" = "x4" ]; then
	            break
	        fi
	    done
	    
	    if [ "x$hw_no" = "x1" ]; then
	        hw_type="3U16-STANDARD"
	    elif [ "x$hw_no" = "x2" ]; then
	        hw_type="3U16-SIMPLE"
	    elif [ "x$hw_no" = "x3" ]; then
	        hw_type="2U8-STANDARD"
	    elif [ "x$hw_no" = "x4" ]; then
	        hw_type="2U8-ATOM"
	    fi
	fi
fi

####
do_transfer "root"  ${dev}1 $ROOT $tar_dir/root.tgz
do_transfer "opt"  ${dev}5 $OPT $tar_dir/opt.tgz
do_transfer "local"  ${dev}1 $LOCAL $tar_dir/local.tgz

if ! mount ${dev}5 $OPT; then
    echo "Error: mount ${dev}5 to $OPT failed for save conf"
    exit 1
fi

CONFDIR_SYSTEM=$OPT/jw-conf/system
mkdir -p $CONFDIR_SYSTEM
cd $CONFDIR_SYSTEM
echo $sw_type >./software-type
echo $hw_type >./hardware-type
ln -sf sysmon-conf.xml.$hw_type sysmon-conf.xml
cd - >/dev/null

CONFDIR_DISK=$OPT/jw-conf/disk
mkdir -p $CONFDIR_DISK
cd $CONFDIR_DISK
ln -sf ata2slot.xml.$hw_type ata2slot.xml
cd - >/dev/null

umount $OPT

exit 0
