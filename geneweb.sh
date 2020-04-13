#!/bin/sh

start() {
	docker build -t raver/geneweb .

	mkdir -p /var/log/geneweb/
	docker run -d -t \
	 -p 2317:2317 \
	 -p 2316:2316 \
	 -l raver/geneweb \
	 -v /var/log/geneweb:/var/log/geneweb \
	 --name geneweb \
	 raver/geneweb:latest \
	 genweb-launch.sh
}

stop() {
	docker stop geneweb
	docker rm geneweb
	status
}

status(){
	docker ps
}

usage(){
	echo "$(basename $0) start|stop|restart|status"
}

case $1 in

	start)
		start
	;;

	stop)
		stop
	;;

	status)
		status
	;;

	*)
		usage
	;;
esac

