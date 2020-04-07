From arm64v8/alpine
#From mor1/arm64v8-alpine_3.8.0-ocaml-4.06.1-opam_1.2.2
# inspired by https://geneweb.tuxfamily.org/wiki/OCaml

MAINTAINER ravermeister <jonny@rimkus.it>

#RUN apk update && apk add --no-cache --update bash ncurses\
# build-base linux-headers coreutils curl-dev make m4 unzip\
# gcc pkgconfig gmp-dev perl-dev git mercurial rsync\
# opam ocaml-dev ocaml-compiler-libs ocaml-findlib-dev ocaml-ocamldoc
#RUN apk update && apk upgrade --no-cache &&\
# apk add --no-cache --update bash ncurses\
# build-base linux-headers coreutils curl-dev make m4 unzip\
# gcc pkgconfig gmp-dev perl-dev git mercurial rsync opam

#RUN opam init -y --disable-sandboxing

RUN apk update && apk add --no-cache --update bash ncurses\
 build-base linux-headers coreutils curl-dev curl make m4 unzip\
 gcc pkgconfig gmp-dev perl-dev git mercurial rsync openssl opam-dev

#RUN curl -s https://raw.githubusercontent.com/ocaml/opam/master/shel/install.sh --output ~/install.sh &&\
# chmod +x ~/install.sh && ~/install.sh && chmod +x $BINDIR/opam

#RUN export PATH="$(opam config var bin):$PATH"
#RUN echo "PATH: >$PATH<"


RUN opam init -y --disable-sandboxing
RUN opam update -a -y
RUN opam upgrade -a -y
#RUN opam install -y --unlock-base camlp5 cppo dune markup ounit uucp unidecode ocurl piqi piqilib redis redis-sync yojson ocamlfind
RUN opam install -y camlp5 cppo dune markup ounit uucp unidecode ocurl piqi piqilib redis redis-sync yojson ocamlfind

RUN mkdir -p /geneweb
RUN git clone https://github.com/geneweb/geneweb /geneweb
RUN cd /geneweb && ocaml ./configure.ml --api && make clean distrib


#RUN cd /geneweb && ./configure && make opt && make distrib
#ADD root/ /
#RUN chmod -v +x /etc/services.d/*/run /etc/cont-init.d/*
