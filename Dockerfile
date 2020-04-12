From arm64v8/alpine
#From mor1/arm64v8-alpine_3.8.0-ocaml-4.06.1-opam_1.2.2
# inspired by https://geneweb.tuxfamily.org/wiki/OCaml

MAINTAINER ravermeister <jonny@rimkus.it>

RUN apk update && apk add --no-cache --update bash ncurses\
 build-base linux-headers coreutils curl-dev make m4 unzip\
 gcc pkgconfig gmp-dev perl-dev git mercurial rsync\
 opam ocaml-dev ocaml-compiler-libs ocaml-findlib-dev ocaml-ocamldoc

RUN opam init -y --disable-sandboxing
RUN opam update -a -y
RUN opam upgrade -a -y
RUN opam install -y camlp5 cppo dune markup ounit uucp unidecode ocurl piqi piqilib redis redis-sync yojson ocamlfind
RUN eval $(opam env)

RUN opam pin add -y geneweb-bin -k git https://github.com/geneweb/geneweb --no-action
RUN opam -y depext geneweb-bin
RUN eval $(opam env)
RUN opam install -y geneweb-bin
RUN eval $(opam env)

################# end of build ####################
