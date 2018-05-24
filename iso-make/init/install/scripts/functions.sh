#!/bin/sh

read_yes_no()
{
    msg=$1
    query=unknown
    while [ "x$query" != "xYES" ] && [ "x$query" != "xNO" ] && [ "x$query" != "xDEBUG" ]; do
        echo "Type 'YES' or 'NO'"
        read -p "$msg [YES/NO]: " query
    done
    if [ "x$query" = "xYES" ]; then
        return 0
    elif [ "x$query" = "xDEBUG" ]; then
        return 1
    else
        reboot
    fi
}
