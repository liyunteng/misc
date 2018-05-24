#!/bin/sh
pid=/var/run/brltty.pid
[ -r $pid ] && kill -0 `cat $pid` && exit 0

echo debconf-set debian-installer/framebuffer false > /lib/debian-installer.d/S20brltty
rm -f /lib/debian-installer/S19brltty

if [ -f /var/run/brltty-debconf ]
then
	rm /var/run/brltty-debconf
	DEBCONF=""
	while [ -z "$DEBCONF"  ]
	do
		DEBCONF=`pidof debconf`
	done
	[ -z "$DEBCONF" ] || kill "$DEBCONF"
fi

exec /sbin/brltty -P $pid "$@"
