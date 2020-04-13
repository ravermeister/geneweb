#!/bin/sh

docker build -t raver/geneweb .

docker run -t \
 -p 2317:2317 \
 -p 2316:2316 \
 -l raver/geneweb \
 raver/geneweb:latest \
 genweb-launch.sh
