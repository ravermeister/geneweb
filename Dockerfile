From arm64v8/alpine

# inspired by https://geneweb.tuxfamily.org/wiki/OCaml

#MAINTAINER fanningert <thomas@fanninger.at>
MAINTAINER ravermeister <jonny@rimkus.it>

RUN apk update
RUN apk add --no-cache --update bash ncurses make m4 unzip bubblewrap gcc gmp-dev perl git rsync mercurial opam

RUN opam init -y --disable-sandboxing
RUN opam update -a -y
#RUN opam switch 4.05.0 4.05.0
#RUN eval $(opam config env)
RUN opam install -y camlp5 cppo dune.1.11.4 markup stdlib-shims num zarith uucp unidecode

RUN mkdir -p /geneweb
RUN git clone https://github.com/geneweb/geneweb /geneweb
RUN cd /geneweb
RUN ./configure && make opt && make distrib

ADD root/ /

RUN chmod -v +x /etc/services.d/*/run /etc/cont-init.d/*
