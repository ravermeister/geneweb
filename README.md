# docker-geneweb
Arm64 (Alpine) Docker for [GeneWeb](https://github.com/geneweb/geneweb "Geneweb Repository").
The generated image is pushed to [docker hub](https://hub.docker.com/r/ravermeister/armhf-geneweb)

## starting
```bash
docker pull ravermeister/armhf-geneweb
docker run -d -t \
	 -p 2317:2317 \
	 -p 2316:2316 \
	 -l raver/geneweb \
	 -v $LOGDIR:/var/log/geneweb \
	 --name geneweb \
	 raver/geneweb:latest \
	 genweb-launch.sh
```
*  gwsetup will be available on localhost:2316
*  gwd will be available on localhost:2317

## developement
```bash
git clone https://gitlab.rimkus.it/genealogy/geneweb-arm64-docker.git geneweb
cd geneweb
./geneweb.sh setup
./geneweb.sh start
```
*  gwsetup will be available on localhost:2316
*  gwd will be available on localhost:2317
