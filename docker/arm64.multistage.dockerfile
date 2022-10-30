FROM arm64v8/debian:stable-slim AS builder
LABEL org.opencontainers.image.authors="Jonny Rimkus " \
description="Geneweb for arm64 on debian-slim"
ENV OPAM_VERSION="4.13.1"
ENV OPAMYES=yes

# Install required packages for build
RUN set -eux; \
  export DEBIAN_FRONTEND=noninteractive && \
  apt-get update -q && \
  apt-get install -yq --no-install-recommends \
    apt-transport-https ca-certificates less nano \
    tzdata libatomic1 vim wget libncurses5-dev \
    build-essential linux-headers-arm64 coreutils curl make m4 unzip gcc \
    pkg-config libgmp-dev libperl-dev libipc-system-simple-perl \
    libstring-shellquote-perl git subversion mercurial rsync \
    libcurl4-openssl-dev musl-dev protobuf-compiler opam rsyslog \
    bubblewrap darcs musl-tools procps && \
  apt-get clean && \
  rm -rf /var/lib/apt/lists/* && \
  rm -rf /etc/update-motd.d /etc/motd /etc/motd.dynamic && \
  ln -fs /dev/null /run/motd.dynamic

RUN rm -rf /usr/local/share/geneweb && \
  mkdir -p /usr/local/share/geneweb && \ 
  adduser --system --group --shell /bin/bash geneweb

USER geneweb:geneweb
WORKDIR /home/geneweb

RUN set -uex; opam init --compiler="$OPAM_VERSION" --disable-sandboxing 
RUN eval $(opam config env) && opam update
RUN git clone https://github.com/geneweb/geneweb.git geneweb 
WORKDIR /home/geneweb/geneweb 
RUN set -uex; eval $(opam env) && opam pin add geneweb.dev . --no-action 
RUN set -uex; eval $(opam env) && opam depext geneweb 
RUN set -uex; ulimit -s unlimited; \
    eval $(opam env) && opam install geneweb --deps-only
RUN set -uex; eval $(opam env) && ocaml ./configure.ml --release
RUN set -uex; eval $(opam env) && make clean distrib

###############################################################################

FROM arm64v8/debian:stable-slim 
LABEL org.opencontainers.image.authors="Jonny Rimkus " \
  description="Geneweb for arm64 on debian-slim"

# Install required packages for runtime
RUN set -eux; \
  export DEBIAN_FRONTEND=noninteractive && \
  apt-get update -q && \
  apt-get install -yq --no-install-recommends \
    apt-transport-https ca-certificates less nano \
    procps tzdata wget curl unzip \
    rsyslog && \
  apt-get clean && \
  rm -rf /var/lib/apt/lists/* && \
  rm -rf /etc/update-motd.d /etc/motd /etc/motd.dynamic && \
  ln -fs /dev/null /run/motd.dynamic

ENV GWSETUP_LANG=de
ENV GWD_LANG=de

RUN adduser --system --group --home /usr/local/share/geneweb --shell /bin/bash geneweb
USER geneweb:geneweb
WORKDIR /usr/local/share/geneweb
RUN mkdir -p bin etc log share/data share/dist \
  && echo "export GWSETUP_LANG=$GWSETUP_LANG" >>.profile \
  && echo "export GWD_LANG="$GWD_LANG" >>.profile
COPY --from=builder /home/geneweb/geneweb/distribution share/dist
RUN mv share/dist/bases share/data
ADD gwsetup_only etc/gwsetup_only
ADD geneweb-launch.sh bin/geneweb-launch.sh

USER root:root

ENTRYPOINT bin/geneweb-launch.sh >/dev/null 2>&1

EXPOSE 2316-2317
EXPOSE 2322

