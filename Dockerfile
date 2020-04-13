From arm64v8/alpine

MAINTAINER ravermeister <jonny@rimkus.it>


RUN apk update && apk add --no-cache --update bash ncurses\
 build-base linux-headers coreutils curl curl-dev\
 make m4 unzip gcc pkgconfig gmp-dev perl-dev git\
 subversion mercurial rsync musl-dev protoc opam
# ocaml-dev ocaml-compiler-libs ocaml-findlib-dev ocaml-ocamldoc
 

RUN opam init -y --disable-sandboxing
RUN opam update -a -y
RUN opam upgrade -a -y
RUN eval $(opam env)

RUN opam switch create 4.08.0
RUN eval $(opam env)
#RUN opam upgrade -y ocaml.4.10.0
#RUN eval $(opam env)

RUN opam pin add -y geneweb-bin -k git https://github.com/geneweb/geneweb --no-action
RUN opam -y depext geneweb-bin
RUN eval $(opam env)
RUN opam install -y geneweb-bin
RUN eval $(opam env)

RUN opam install -y --unlock-base camlp5 cppo dune jingoo\
 markup ounit uucp unidecode ocurl piqi piqilib redis redis-sync yojson
RUN eval $(opam env)

#RUN cd /root/.opam/default/.opam-switch/build/geneweb-bin.~dev && \
#ocaml ./configure.ml --api && \
#make clean distrib
