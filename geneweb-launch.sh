#!/bin/bash
# Jonny Rimkus <jonny@rimkus.it>
# Geneweb start script for use inside the docker image

GWD_PID=
GWD_STATUS=
GWSETUP_PID=
GWSETUP_STATUS=

GWSETUP_LANG=de
GWD_LANG=de
LOGDIR=/var/log/geneweb
DISTDIR=/root/.opam/4.10.0/.opam-switch/build/geneweb-bin.~dev/distribution

isalive(){
	if [ $GWD_STATUS -ne 0 -o $GWSETUP_STATUS -ne 0 ]; then
		echo "gwsetup or gwd has died!" >&2
		exit 1
	fi
}

init() {
	eval $(opam env)
	mkdir -p $LOGDIR
	cd $DISTDIR
}

start() {
	init
	./gwsetup -daemon -lang $GWSETUP_LANG >>$LOGDIR/gwsetup.log 2>&1
	GWSETUP_PID=$!
	GWSETUP_STATUS=$?

	./gwd -daemon -lang $GWD_LANG -log $LOGDIR/gwd.log >>$LOGDIR/gwd.log 2>&1
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

