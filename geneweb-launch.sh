#!/bin/sh
# Jonny Rimkus <jonny@rimkus.it>
# Geneweb start script for use inside the docker image

eval $(opam env)
cd /root/.opam/4.10.0/.opam-switch/build/geneweb-bin.~dev/distribution

bin/gwd 2>&1 >/var/log/gwd.log &
bin/gwsetup 2>&1 >/var/log/gwsetup &

echo "gwd and gwsetup successfully started"
