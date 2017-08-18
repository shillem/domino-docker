FROM debian:8.8

ENV DEBIAN_FRONTEND noninteractive

COPY resources/ /tmp/res

RUN apt-get update && apt-get install -y \
  cpio \
  nano \
  screen \
  wget

RUN groupadd notes && \
  useradd -m -s /bin/bash -g notes notes

RUN mkdir -p /tmp/res && \
  cd /tmp/res && \
  wget -q http://172.17.0.1:7777/Public/Binaries/IBM/Domino/Linux/DOMINO_9.0.1_64_BIT_LIN_XS_EN.tar && \
  tar -xf *.tar && \
  cd linux64/domino && \
  bash -c "./install -silent -options /tmp/res/unix_response.dat" && \
  cd /tmp/res && \
  rm -R /tmp/*
