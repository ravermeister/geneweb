From arm64v8/alpine
MAINTAINER ravermeister <jonny@rimkus.it>

ENV OPAM_VERSION="4.10.0"

RUN apk update && apk add --no-cache --update bash ncurses\
 build-base linux-headers coreutils curl make m4 unzip gcc\
 pkgconfig gmp-dev perl-dev git subversion mercurial rsync\
 curl-dev musl-dev redis protoc opam

RUN adduser -D -h /usr/local/share/geneweb -s /bin/bash geneweb geneweb
USER geneweb:geneweb

WORKDIR /usr/local/share/geneweb
RUN mkdir etc &&\
 mkdir bin &&\
 mkdir -p share/redis &&\
 mkdir log &&\
 mkdir tmp

RUN opam init -y --disable-sandboxing
RUN eval $(opam env) && opam update -a -y
RUN eval $(opam env) && opam upgrade -a -y
RUN eval $(opam env) && opam switch create "$OPAM_VERSION"
RUN eval $(opam env) && opam install -y --unlock-base camlp5 cppo dune jingoo\
 markup ounit uucp uunf unidecode ocurl piqi piqilib redis redis-sync yojson

RUN eval $(opam env) && opam pin add -y geneweb-bin -k git https://github.com/geneweb/geneweb#master --no-action
RUN eval $(opam env) && opam -y depext geneweb-bin
RUN eval $(opam env) && opam install -y geneweb-bin

WORKDIR .opam/4.10.0/.opam-switch/build/geneweb-bin.~dev
RUN [ -f distribution/commit.txt ] && rm -f distribution/commit.txt
RUN [ -f hd/etc/version.txt ] && rm -f hd/etc/version.txt
RUN eval $(opam env) && ocaml ./configure.ml --api
RUN eval $(opam env) && make clean distrib
RUN mv distribution /usr/local/share/geneweb/share/dist

WORKDIR /usr/local/share/geneweb
ADD assets/gwsetup_only etc/gwsetup_only
ADD assets/geneweb-launch.sh bin/geneweb-launch.sh
ADD assets/redis.conf /etc/redis.conf

RUN mv share/dist/bases share/data

USER root
ENTRYPOINT bin/geneweb-launch.sh >/dev/null 2>&1

EXPOSE 2316-2317
EXPOSE 2322
