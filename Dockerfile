From arm64v8/alpine

MAINTAINER ravermeister <jonny@rimkus.it>

RUN apk update && apk add --no-cache --update bash ncurses\
 build-base linux-headers coreutils curl-dev make m4 unzip\
 gcc pkgconfig gmp-dev perl-dev git mercurial rsync\
 opam ocaml-dev ocaml-compiler-libs ocaml-findlib-dev\
 ocaml-ocamldoc protoc

RUN opam init -y --disable-sandboxing
RUN opam update -a -y
RUN opam upgrade -a -y
#RUN opam install -y camlp5 cppo dune markup ounit uucp unidecode ocurl piqi piqilib redis redis-sync yojson ocamlfind
RUN opam install -y camlp5 cppo dune jingoo markup ounit uucp unidecode ocurl piqi piqilib redis redis-sync yojson
RUN eval $(opam env)

RUN opam pin add -y geneweb-bin -k git https://github.com/geneweb/geneweb --no-action
RUN opam -y depext geneweb-bin
RUN eval $(opam env)
RUN opam install -y geneweb-bin
RUN eval $(opam env)

RUN cd /root/.opam/default/.opam-switch/build/geneweb-bin.~dev && \
ocaml ./configure.ml --api && \
make clean distrib
