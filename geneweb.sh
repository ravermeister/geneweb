#!/bin/sh

LOGDIR=$(dirname $(readlink -f '$0'))/log
CONFDIR=$(dirname $(readlink -f '$0'))/config
DATADIR=$(dirname $(readlink -f '$0'))/data

GWD_PORT=2317
GWSETUP_PORT=2316
GWAPI_PORT=2322

build() {
	if [ "$1" = "--force" ]; then
		docker build --no-cache -t raver/geneweb .
	else
		docker build -t raver/geneweb .
	fi
	mkdir -p $DATADIR
	mkdir -p $LOGDIR
}

setup(){
	docker pull ravermeister/armhf-geneweb
	mkdir -p $DATADIR
	mkdir -p $LOGDIR
}

start() {
	docker run -d -t \
	 -p $GWD_PORT:2317 \
	 -p $GWSETUP_PORT:2316 \
	 -p $GWAPI_PORT:2322 \
	 -v $CONFDIR:/usr/local/share/geneweb/etc \
	 -v $DATADIR:/usr/local/share/geneweb/share/data \
	 -v $LOGDIR:/usr/local/share/geneweb/log \
	 --restart always \
	 -l raver/geneweb \
	 --name geneweb \
	 raver/geneweb:latest
}

stop() {
	docker stop geneweb >/dev/null 2>&1
	docker rm geneweb >/dev/null 2>&1
}

status(){
	docker ps
}

usage(){
	echo "$(basename $0) build [--force]"
	echo "$(basename $0) setup|start|stop|restart|status"
}

case $1 in

	setup)
		echo "pulling newest stable image"
		setup
	;;

	build)
		echo "building docker image"
		build $2
	;;

	start)
		echo -n "Starting..."
		start
		echo "Done"
		status
	;;

	stop)
		echo -n "Stopping..."
		stop
		echo "Done"
		status
	;;

	restart)
		echo -n "Stopping..."
		stop
		echo "Done"
		echo -n "Starting..."
		start
		echo "Done"
		status
	;;

	status)
		status
	;;

	*)
		usage
	;;
esac

exit 0

