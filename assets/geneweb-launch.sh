#!/bin/bash
# Jonny Rimkus <jonny@rimkus.it>
# Geneweb start script for use inside the docker image

GWD_PID=
GWD_STATUS=

GWSETUP_PID=
GWSETUP_STATUS=

REDIS_PID=
REDIS_STATUS=

GWSETUP_LANG=de
GWD_LANG=de

## runs as geneweb
isalive(){
	if [ $GWD_STATUS -ne 0 -o $GWSETUP_STATUS -ne 0 -o $REDIS_STATUS -ne 0 ]; then
		echo "either gwsetup, gwd or redis has died!" >&2
		exit 1
	fi
}

## runs as geneweb
start() {
	eval $(opam env)

	/usr/bin/redis-server etc/redis.conf >>log/redis.log 2>&1 &
	REDIS_PID=$!
	REDIS_STATUS=$?

	cd share/data

	../dist/gw/gwsetup \
	-daemon \
	-gd ../dist/gw \
	-only ../../etc/gwsetup_only \
	-lang $GWSETUP_LANG \
	>>../../log/gwsetup.log 2>&1
	GWSETUP_PID=$!
	GWSETUP_STATUS=$?

	GWD_AUTH_FILE=/usr/local/share/geneweb/etc/gwd_passwd

	if [ -f $GWD_AUTH_FILE ]; then
		../dist/gw/gwd \
		-daemon \
		-trace_failed_passwd \
		-auth $GWD_AUTH_FILE \
		-hd ../dist/gw \
		-lang $GWD_LANG \
		-blang \
		-log ../../log/gwd.log \
		>>../../log/gwd.log 2>&1
		GWD_PID=$!
		GWD_STATUS=$?
	else
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
	fi

	isalive
	echo "gwsetup, gwd and redis started!"
	watch
}

## runs as geneweb
watch() {

	while sleep 60; do
		ps aux | grep gwsetup | grep -q -v grep GWSETUP_STATUS
		ps aux | grep gwd | grep -q -v grep GWD_STATUS
		ps aux | grep redis-server | grep -q -v grep REDIS_STATUS
		isalive
	done
}


## main routine
start

exit 0

