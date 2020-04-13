From arm64v8/alpine

MAINTAINER ravermeister <jonny@rimkus.it>


RUN apk update && apk add --no-cache --update bash ncurses\
 build-base linux-headers coreutils curl make m4 unzip gcc\
 pkgconfig gmp-dev perl-dev git subversion mercurial rsync\
 curl-dev musl-dev protoc opam

RUN opam init -y --disable-sandboxing
RUN eval $(opam env) && opam update -a -y
RUN eval $(opam env) && opam upgrade -a -y
RUN eval $(opam env) && opam switch create 4.10.0
RUN eval $(opam env) && opam install -y --unlock-base camlp5 cppo dune jingoo\
 markup ounit uucp unidecode ocurl piqi piqilib redis redis-sync yojson

RUN eval $(opam env) && opam pin add -y geneweb-bin -k git https://github.com/geneweb/geneweb --no-action
RUN eval $(opam env) && opam -y depext geneweb-bin
RUN eval $(opam env) && opam install -y geneweb-bin

RUN cd /root/.opam/4.10.0/.opam-switch/build/geneweb-bin.~dev
RUN eval $(opam env) &&\
 cd /root/.opam/4.10.0/.opam-switch/build/geneweb-bin.~dev &&\
 ocaml ./configure.ml --api
RUN eval $(opam env) &&\
 cd /root/.opam/4.10.0/.opam-switch/build/geneweb-bin.~dev &&\
  make clean distrib
