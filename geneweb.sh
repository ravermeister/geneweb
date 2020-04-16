#!/bin/sh

LOGDIR=$(dirname $(readlink -f '$0'))/log
CONFDIR=$(dirname $(readlink -f '$0'))/config
DATADIR=$(dirname $(readlink -f '$0'))/data

GWD_PORT=2317
GWSETUP_PORT=2316

build() {
	docker build -t raver/geneweb .
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
	 -l raver/geneweb \
	 -v $CONFDIR:/etc/geneweb \
	 -v $DATADIR:/var/local/geneweb/data \
	 -v $LOGDIR:/var/log/geneweb \
	 --name geneweb \
	 raver/geneweb:latest \
	 geneweb-launch.sh >/dev/null 2>&1
}

stop() {
	docker stop geneweb >/dev/null 2>&1
	docker rm geneweb >/dev/null 2>&1
}

status(){
	docker ps
}

usage(){
	echo "$(basename $0) build|setup|start|stop|restart|status"
}

case $1 in

	setup)
		echo "pulling newest stable image"
		setup
	;;

	build)
		echo "building docker image"
		build
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
		echo "Starting..."
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

