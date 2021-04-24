FROM arm64v8/debian:stable-slim
LABEL maintainer="Jonny Rimkus <jonny@rimkus.it>"

ENV OPAM_VERSION="4.11.1"

# Install required packages
RUN set -eux; \
    export DEBIAN_FRONTEND=noninteractive && \
    apt-get update -q && \
    apt-get install -yq --no-install-recommends \
      apt-transport-https ca-certificates less nano \
      tzdata libatomic1 vim wget libncurses5-dev \
      build-essential linux-headers-arm64 coreutils curl make m4 unzip gcc \
      pkg-config libgmp-dev libperl-dev libipc-system-simple-perl \
      libstring-shellquote-perl git subversion mercurial rsync \
      libcurl4-openssl-dev musl-dev redis protobuf-compiler opam rsyslog \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/* \
    # Remove MOTD
    && rm -rf /etc/update-motd.d /etc/motd /etc/motd.dynamic \
    && ln -fs /dev/null /run/motd.dynamic

RUN rm -rf /usr/local/share/geneweb && \
 mkdir -p /usr/local/share/geneweb && \
 adduser --system --group --home /usr/local/share/geneweb --shell /bin/bash geneweb && \
 chown -R geneweb:geneweb /usr/local/share/geneweb

USER geneweb:geneweb
WORKDIR /usr/local/share/geneweb
RUN mkdir etc && \
 mkdir bin && \
 mkdir -p share/redis && \
 mkdir log && \
 mkdir tmp

RUN opam init -y --disable-sandboxing && \
 eval $(opam env) && opam update -a -y && \
 eval $(opam env) && opam upgrade -a -y && \
 eval $(opam env) && opam switch create "$OPAM_VERSION" && \
 eval $(opam env) && opam install -y --unlock-base \
 camlp5.7.13 cppo dune jingoo markup ounit uucp uunf \
 unidecode ocurl piqi piqilib redis redis-sync yojson \
 calendars syslog

WORKDIR "/usr/local/share/geneweb/.opam/$OPAM_VERSION/.opam-switch/build"
RUN git clone https://github.com/geneweb/geneweb geneweb

WORKDIR "/usr/local/share/geneweb/.opam/$OPAM_VERSION/.opam-switch/build/geneweb"
RUN eval $(opam env) && ocaml ./configure.ml --api && make clean distrib
RUN rm -rf /usr/local/share/geneweb/share/dist && mv distribution /usr/local/share/geneweb/share/dist

WORKDIR /usr/local/share/geneweb
RUN mv share/dist/bases share/data
ADD gwsetup_only etc/gwsetup_only
ADD geneweb-launch.sh bin/geneweb-launch.sh
ADD redis.conf /etc/redis.conf

USER root
ENTRYPOINT bin/geneweb-launch.sh >/dev/null 2>&1

EXPOSE 2316-2317
EXPOSE 2322
