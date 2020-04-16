#!/bin/bash
# Jonny Rimkus <jonny@rimkus.it>
# Geneweb start script for use inside the docker image

GWD_PID=
GWD_STATUS=
GWSETUP_PID=
GWSETUP_STATUS=

GWSETUP_LANG=de
GWD_LANG=de

isalive(){
	if [ $GWD_STATUS -ne 0 -o $GWSETUP_STATUS -ne 0 ]; then
		echo "gwsetup or gwd has died!" >&2
		exit 1
	fi
}

init() {
	chown -R geneweb:geneweb share/data
	chown -R geneweb:geneweb etc
	chown -R geneweb:geneweb log
}

start() {
	eval $(opam env)
	cd share/data

	../dist/gw/gwsetup \
	-daemon \
	-gd ../dist/gw \
	-only ../../etc/gwsetup_only \
	-lang $GWSETUP_LANG \
	>>../../log/gwsetup.log 2>&1
	GWSETUP_PID=$!
	GWSETUP_STATUS=$?

	../dist/gw/gwd \
	-daemon \
	-trace_failed_passwd \
	-hd ../dist/gw \
	-lang $GWD_LANG \
	-blang \
	-log ../../log/gwd.log \
	>>../../log/gwd.log 2>&1
	GWD_PID=$!
	GWD_STATUS=$?

	isalive
	echo "gwd and gwsetup started!"
	watch
}

watch() {

	while sleep 60; do
		ps aux | grep gwsetup | grep -q -v grep GWSETUP_STATUS
		ps aux | grep gwd | grep -q -v grep GWD_STATUS
		isalive
	done
}

if [ $(id -u) -eq 0 ]; then
	init
	su -c "$0" -l geneweb
else
	start
fi

exit 0

