#!/bin/sh

docker build -t raver/geneweb .

mkdir -p /var/log/geneweb/
docker run -d -t \
 -p 2317:2317 \
 -p 2316:2316 \
 -l raver/geneweb \
 -v /var/log/geneweb:/var/log/geneweb \
 raver/geneweb:latest \
 genweb-launch.sh
