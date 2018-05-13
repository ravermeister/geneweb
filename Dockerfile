FROM fanningert/baseimage-alpine

MAINTAINER fanningert <thomas@fanninger.at>

RUN apk update && \
	apk add --no-cache --update bash && \
	apk add --no-cache --update opam && \
        apk add --no-cache --update git

RUN opam init
RUN opam update
RUN opam switch 4.05.0
RUN eval `opam config env`
RUN opam install -y ocamlfind camlp5

RUN mkdir -p /geneweb
RUN git clone https://github.com/geneweb/geneweb /geneweb
RUN cd /geneweb
RUN ./configure && make opt && make distrib

ADD root/ /

RUN chmod -v +x /etc/services.d/*/run /etc/cont-init.d/*
