#!/bin/sh

LOGDIR=/var/log/geneweb
CONFDIR=$(readlink -f "$0")/config
setup() {
	docker build -t raver/geneweb $(readlink -f "$0")/assets
	mkdir -p $LOGDIR
}

start() {
	docker run -d -t \
	 -p 2317:2317 \
	 -p 2316:2316 \
	 -l raver/geneweb \
	 -v $LOGDIR:/var/log/geneweb \
	 -v $CONFDIR:/etc/geneweb
	 --name geneweb \
	 raver/geneweb:latest \
	 genweb-launch.sh >/dev/null 2>&1
}

stop() {
	docker stop geneweb >/dev/null 2>&1
	docker rm geneweb >/dev/null 2>&1
}

status(){
	docker ps
}

usage(){
	echo "$(basename $0) setup|start|stop|restart|status"
}

case $1 in

	setup)
		echo "building docker image"
		setup
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

