FROM arm64v8/debian:stable-slim
LABEL maintainer="Jonny Rimkus <jonny@rimkus.it>"

ENV OPAM_VERSION="4.11.1"

# Install required packages
RUN set -eux; \
    export DEBIAN_FRONTEND=noninteractive &&\
    apt-get update -q &&\
    apt-get install -yq --no-install-recommends \
      apt-transport-https ca-certificates less nano \
      tzdata libatomic1 vim wget ncurses \
      build-base linux-headers coreutils curl make m4 unzip gcc \
      pkgconfig gmp-dev perl-dev perl-ipc-system-simple \
      perl-string-shellquote git subversion mercurial rsync \
      curl-dev musl-dev redis protoc opam rsyslog
    && rm -rf /var/lib/apt/lists/* \
    && sed 's/session\s*required\s*pam_loginuid.so/session optional pam_loginuid.so/g' -i /etc/pam.d/sshd \
    # Remove MOTD
    && rm -rf /etc/update-motd.d /etc/motd /etc/motd.dynamic \
    && ln -fs /dev/null /run/motd.dynamic

RUN rm -rf /usr/local/share/geneweb &&\
 mkdir -p /usr/local/share/geneweb &&\
 adduser -D -h /usr/local/share/geneweb -s /bin/bash geneweb geneweb &&\
 chown -R geneweb:geneweb /usr/local/share/geneweb

USER geneweb:geneweb
WORKDIR /usr/local/share/geneweb
RUN mkdir etc &&\
 mkdir bin &&\
 mkdir -p share/redis &&\
 mkdir log &&\
 mkdir tmp

RUN opam init -y --disable-sandboxing &&\
 eval $(opam env) && opam update -a -y &&\
 eval $(opam env) && opam upgrade -a -y &&\
 eval $(opam env) && opam switch create "$OPAM_VERSION" &&\
 eval $(opam env) && opam install -y --unlock-base\
 camlp5.7.13 cppo dune jingoo markup ounit uucp uunf\
 unidecode ocurl piqi piqilib redis redis-sync yojson\
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
