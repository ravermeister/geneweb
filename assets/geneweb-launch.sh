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
	eval $(opam env)
}

start() {
	init
	share/dist/gw/gwsetup \
	-daemon \
	-bd share/data \
	-gd share/dist/gw
	-only etc/gwsetup_only \
	-lang $GWSETUP_LANG \
	>>log/gwsetup.log 2>&1
	GWSETUP_PID=$!
	GWSETUP_STATUS=$?

	share/dist/gw/gwd \
	-daemon \
	-a 127.0.0.1 \
	-hd share/dist/gw \
	-bd share/data \
	-trace_failed_passwd \
	-lang $GWD_LANG \
	-blang $GWD_LANG \
	-log log/gwd.log \
	>>log/gwd.log 2>&1
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

start

exit 0

