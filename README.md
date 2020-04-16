# docker-geneweb
Arm64 (Alpine) Docker for [GeneWeb](https://github.com/geneweb/geneweb "Geneweb Repository").
The generated image is pushed to [docker hub](https://hub.docker.com/r/ravermeister/armhf-geneweb)

## Quickstart
```bash
git clone https://gitlab.rimkus.it/genealogy/geneweb-arm64-docker.git geneweb
cd geneweb
./geneweb.sh setup
./geneweb.sh start
```
*  gwsetup will be available on localhost:2316
*  gwd will be available on localhost:2317

Note, if you would like to build the container from the raw Dockerfile use 
`./geneweb build` instead of `./geneweb setup`

for gwsetup you must edit the `config/gwsetup_only` file and 
replace the IP with the local IP or Hostname where the docker container runs within.
Note that you have to rerun the `./geneweb setup` and restart the container to have the settings applied.


## starting (without git checkout)
```bash
# prepare shared folders
CONFDIR=/etc/geneweb
LOGDIR=/var/log/geneweb
DATADIR=/var/local/geneweb
mkdir -p $CONFDIR
echo "127.0.0.1" >$CONFDIR/gwsetup_only
mkdir -p $DATADIR
mkdir -p $LOGDIR
# pull the image
docker pull ravermeister/armhf-geneweb
#run the image
docker run -d -t \
-p 2317:2317 \
-p 2316:2316 \
-l raver/geneweb \
-v $CONFDIR:/etc/geneweb \
-v $DATADIR:/root/.opam/4.10.0/.opam-switch/build/geneweb-bin.~dev/distribution/bases \
-v $LOGDIR:/var/log/geneweb \
--name geneweb \
raver/geneweb:latest \
geneweb-launch.sh
```
for gwsetup you must edit the `$CONFDIR/gwsetup_only` file and 
replace the IP with the local IP or Hostname where the docker container runs within.

*  gwsetup will be available on localhost:2316
*  gwd will be available on localhost:2317
