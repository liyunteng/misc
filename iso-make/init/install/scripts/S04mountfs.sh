#!/bin/sh

source functions.sh
source conf.sh

dev=$(cat $TARGET_FILE)
if [ ! -b "$dev" ]; then
    echo "Disk $dev not found"
    exit 1;
fi

mkdir -p $ROOT_DIR $OPT_DIR $LOCAL_DIR

if ! mount ${dev}1 $ROOT_DIR ; then
    echo "ERROR: mount root failed"
    exit 1
fi

if ! mount ${dev}5 $OPT_DIR ; then
    echo "ERROR: mount opt failed"
    exit 1
fi

if ! mount ${dev}6 $LOCAL_DIR ; then
    echo "ERROR: mount local failed"
    exit 1
fi
