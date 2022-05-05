FROM arm32v7/debian:stable-slim
LABEL maintainer="Jonny Rimkus <jonny@rimkus.it>"

ENV OPAM_VERSION="4.13.1"
ENV OPAMYES=yes

# Install required packages
RUN set -eux; \
  export DEBIAN_FRONTEND=noninteractive && \
  apt-get update -q && \
  apt-get install -yq --no-install-recommends \
    apt-transport-https ca-certificates less nano \
    tzdata libatomic1 vim wget libncurses5-dev \
    build-essential linux-headers-armmp coreutils curl make m4 unzip gcc \
    pkg-config libgmp-dev libperl-dev libipc-system-simple-perl \
    libstring-shellquote-perl git subversion mercurial rsync \
    libcurl4-openssl-dev musl-dev redis protobuf-compiler opam rsyslog \
    bubblewrap darcs musl-tools && \
  apt-get clean && \
  rm -rf /var/lib/apt/lists/* && \
  rm -rf /etc/update-motd.d /etc/motd /etc/motd.dynamic && \
  ln -fs /dev/null /run/motd.dynamic

RUN rm -rf /usr/local/share/geneweb && \
  adduser --system --group --home /usr/local/share/geneweb --shell /bin/bash geneweb

USER geneweb:geneweb
WORKDIR /usr/local/share/geneweb

RUN ulimit -s unlimited && \
  opam init -y --disable-sandboxing && \
  eval $(opam env) && opam update -a -y && \
  eval $(opam env) && opam upgrade -a -y && \
  eval $(opam env) && opam switch create "$OPAM_VERSION" && \
  mkdir -p etc bin share/redis log tmp && \
  cd .opam/$OPAM_VERSION/.opam-switch/build && \
  git clone https://github.com/geneweb/geneweb.git geneweb && cd geneweb && \
  eval $(opam env) && opam pin add geneweb.dev . --no-action && \
  eval $(opam env) && opam depext geneweb && \
  eval $(opam env) && opam install geneweb --deps-only && \
  eval $(opam env) && ocaml ./configure.ml --release && \
  eval $(opam env) && opam exec -- make clean distrib && \
  rm -rf ~/share/dist && mv distribution ~/share/dist && \
  rm -rf .opam/$OPAM_VERSION/.opam-switch/build/geneweb && \
  cd ~ && mv share/dist/bases share/data

ADD gwsetup_only etc/gwsetup_only
ADD geneweb-launch.sh bin/geneweb-launch.sh
ADD redis.conf /etc/redis.conf

USER root
ENTRYPOINT bin/geneweb-launch.sh >/dev/null 2>&1

EXPOSE 2316-2317
EXPOSE 2322
