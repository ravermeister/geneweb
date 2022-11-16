#!/bin/sh

LOGDIR=$(dirname $(readlink -f $0))/log
CONFDIR=$(dirname $(readlink -f $0))/config
DATADIR=$(dirname $(readlink -f $0))/data

GWD_PORT=2317
GWSETUP_PORT=2316

DOCKER_IMAGE="ravermeister/geneweb"

build() {
	if [ "$1" = "--force" ]; then
		docker build --no-cache -t "$DOCKER_IMAGE" .
	else
		docker build -t "$DOCKER_IMAGE" .
	fi
	mkdir -p $DATADIR
	mkdir -p $LOGDIR
}

setup(){
	#docker rmi "$DOCKER_IMAGE" >/dev/null 2>&1
	docker pull "$DOCKER_IMAGE"
	mkdir -p $DATADIR
	mkdir -p $LOGDIR
}

start() {
	docker run -d -t \
	 -p $GWD_PORT:2317 \
	 -p $GWSETUP_PORT:2316 \
	 -v $CONFDIR:/usr/local/share/geneweb/etc \
	 -v $DATADIR:/usr/local/share/geneweb/share/data \
	 -v $LOGDIR:/usr/local/share/geneweb/log \
	 --restart always \
	 --name geneweb \
	 "$DOCKER_IMAGE"
}

stop() {
	docker stop geneweb >/dev/null 2>&1
	docker rm geneweb >/dev/null 2>&1
}

status(){
	docker ps
}

update(){
	echo -n "stopping..."
	stop 2>&1 >/dev/null
	echo "done"

	setup

	echo -n "starting..."
	start 2>&1 >/dev/null
	echo "done"

	status
}

usage(){
	echo "$(basename $0) build [--force]"
	echo "$(basename $0) setup|start|stop|restart|status|update"
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

	update)
		update
	;;

	status)
		status
	;;

	*)
		usage
	;;
esac

exit 0

