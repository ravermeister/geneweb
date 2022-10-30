# geneweb
arm64 (debian:stable-slim) Docker for [GeneWeb](https://github.com/geneweb/geneweb "Geneweb Repository").
The generated image is pushed to [docker hub](https://hub.docker.com/r/ravermeister/geneweb)  

## Quickstart
```bash
git clone https://gitlab.rimkus.it/web/geneweb.git geneweb
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
echo "172.17.0.1" >$CONFDIR/gwsetup_only
mkdir -p $DATADIR
mkdir -p $LOGDIR
# pull the image
docker pull ravermeister/geneweb
#run the image
docker run -d -t \
-e GWSETUP_LANG=de \
-e GWD_LANG=DE \
-p $GWD_PORT:2317 \
-p $GWSETUP_PORT:2316 \
-p $GWAPI_PORT:2322 \
-v $CONFDIR:/usr/local/share/geneweb/etc \
-v $DATADIR:/usr/local/share/geneweb/share/data \
-v $LOGDIR:/usr/local/share/geneweb/log \
--restart always \
--name geneweb \
ravermeister/geneweb
```

for gwsetup you must edit the `$CONFDIR/gwsetup_only` file and 
replace the IP with the local IP or Hostname where the docker container runs within.  
The env vars `GWSETUP_LANG` and `GWD_LANG` are optional and set to `de` per default.

*  gwsetup will be available on localhost:2316
*  gwd will be available on localhost:2317

## Configuration
there are 3 folders which are currently exposed:
*  log -> all log files are written into this folder
*  config -> all neccessary config files. Note you can overwrite the default `redis.conf` 
*  data -> all geneweb databases. You can create an authority file for gwd where each line is e.g `user:password`. 
The file __must__ be called `gwd_passwd` because the `geneweb-launch.sh` 
starts gwd with the correct runtime argument when the file is found.
