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

isalive(){
	if [ $GWD_STATUS -ne 0 -o $GWSETUP_STATUS -ne 0 -o $REDID_STATUS ]; then
		echo "gwsetup or gwd has died!" >&2
		exit 1
	fi
}

init() {
	chown -R geneweb:geneweb share/data
	chown -R geneweb:geneweb etc
	chown -R geneweb:geneweb log

	if [ -f "etc/redis.conf" ]; then
		cp etc/redis.conf /etc
		chown root:root /etc/redis.conf
		chmod +r /etc/redis.conf
	fi
}

start() {
	eval $(opam env)

	/usr/bin/redis-server /etc/redis.conf >>log/redis.log 2>&1 &
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
		-redis 127.0.0.1 \
		-redis_p 6379 \
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
		-redis 127.0.0.1 \
		-redis_p 6379 \
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
	echo "redis gwd and gwsetup started!"
	watch
}

watch() {

	while sleep 60; do
		ps aux | grep gwsetup | grep -q -v grep GWSETUP_STATUS
		ps aux | grep gwd | grep -q -v grep GWD_STATUS
		ps aux | grep redis-server | grep -q -v grep REDIS_STATUS
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

