#!/bin/sh

export MAX_SIZE=$((100 * 1000 * 1000 * 2))
export MIN_SIZE=$((7 * 1000 * 1000 * 2))
export TARGET_FILE="/tmp/target"
export INSTALL_DIR="/install"

SOURCE=/source
ROOT_DEV=/root_dev
ISO_PREFIX="jw-"
ROOT_SIZE=8192000
OPT_SIZE=2048000
LOCAL_SIZE=2048000

ROOT_DIR=/tmp/root
OPT_DIR=/tmp/opt
LOCAL_DIR=/tmp/local

export SYS_6026B_T="1001"
export SYS_6026N_T="1002"
export SYS_6036B_T="1003"
export SYS_6036C_T="1004"
export SYS_6036Z_T="1005"

