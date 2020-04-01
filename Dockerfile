From arm64v8/alpine

#MAINTAINER fanningert <thomas@fanninger.at>
MAINTAINER ravermeister <jonny@rimkus.it>

RUN apk update
RUN apk add --no-cache --update bash ncurses opam git m4 make

RUN opam init -y --disable-sandboxing
RUN opam update
#RUN opam switch 4.05.0 4.05.0
#RUN eval `opam config env`
RUN opam config env
RUN opam install -y ocamlfind camlp5

RUN mkdir -p /geneweb
RUN git clone https://github.com/geneweb/geneweb /geneweb
RUN cd /geneweb
RUN ./configure && make opt && make distrib

ADD root/ /

RUN chmod -v +x /etc/services.d/*/run /etc/cont-init.d/*
