From arm64v8/alpine

# inspired by https://geneweb.tuxfamily.org/wiki/OCaml

#MAINTAINER fanningert <thomas@fanninger.at>
MAINTAINER ravermeister <jonny@rimkus.it>

RUN apk update
RUN apk add --no-cache --update bash ncurses build-base linux-headers coreutils \
 curl-dev make m4 unzip gcc pkgconfig gmp-dev perl-dev git mercurial rsync \
 opam ocaml-dev ocaml-compiler-libs ocaml-findlib-dev ocaml-ocamldoc

RUN opam init -y --disable-sandboxing
#RUN opam update -a -y
#RUN opam switch create 4.05.0 
#RUN opam switch create 4.06.0
#RUN eval $(opam config env)
#RUN eval $(opam env)
#RUN opam install -y camlp5 cppo dune markup ounit ocurl piqi piqilib redis redis-sync yojson stdlib-shims num zarith uucp unidecode
RUN opam install -y camlp5 cppo dune markup ounit uucp unidecode ocurl piqi piqilib redis redis-sync yojson

RUN mkdir -p /geneweb
RUN git clone https://github.com/geneweb/geneweb /geneweb

RUN cd /geneweb && ocaml ./configure.ml --api && make clean distrib

#RUN cd /geneweb && ./configure && make opt && make distrib

#ADD root/ /
#RUN chmod -v +x /etc/services.d/*/run /etc/cont-init.d/*
