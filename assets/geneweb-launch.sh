#!/bin/bash
# Jonny Rimkus <jonny@rimkus.it>
# Geneweb start script for use inside the docker image

GWD_STATUS=
GWSETUP_STATUS=

# set via docker env variable
#GWSETUP_LANG=de
#GWD_LANG=de

## runs as geneweb
isalive(){
	if [ $GWD_STATUS -ne 0 -o $GWSETUP_STATUS -ne 0 ]; then
		echo "either gwsetup or gwd has died!" >&2
		exit 1
	fi
}

## runs as root
init() {
	chown -R geneweb:geneweb share/data
	chown -R geneweb:geneweb etc
	chown -R geneweb:geneweb log

	/usr/sbin/rsyslogd >/dev/null 2>&1
}

## runs as geneweb
start() {
	cd share/data

	../dist/gw/gwsetup \
	-daemon \
	-gd ../dist/gw \
	-only ../../etc/gwsetup_only \
	-lang $GWSETUP_LANG \
	>>../../log/gwsetup.log 2>&1
	GWSETUP_STATUS=$?

	GWD_AUTH_FILE=/usr/local/share/geneweb/etc/gwd_passwd

	if [ -f $GWD_AUTH_FILE ]; then
		../dist/gw/gwd \
		-daemon \
                -plugins -unsafe ../dist/gw/plugins \
		-trace_failed_passwd \
		-auth $GWD_AUTH_FILE \
		-hd ../dist/gw \
		-lang $GWD_LANG \
		-blang \
		-log ../../log/gwd.log \
		>>../../log/gwd.log 2>&1
		GWD_STATUS=$?
	else
		../dist/gw/gwd \
		-daemon \
                -plugins -unsafe ../dist/gw/plugins \
		-trace_failed_passwd \
		-hd ../dist/gw \
		-lang $GWD_LANG \
		-blang \
		-log ../../log/gwd.log \
		>>../../log/gwd.log 2>&1
		GWD_STATUS=$?
	fi

	isalive
	echo "gwsetup and gwd started!"
	watch
}

## runs as geneweb
watch() {
	while sleep 60; do
		ps -eo comm | grep -q gwsetup
		GWSETUP_STATUS=$?
		ps -eo comm | grep -q gwd
		GWD_STATUS=$?
		isalive
	done
}



## main routine
## run init things as root (set permissions etc.)
## run the startup routine as correct geneweb user
if [ $(id -u) -eq 0 ]; then
	init
	su -c "$0" -l geneweb \
	   -w GWD_LANG \
	   -w GWSETUP_LANG
else
	start
fi

exit 0

