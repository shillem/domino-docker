FROM debian:10-slim

ENV DEBIAN_FRONTEND noninteractive

ARG IMAGE_FOLDER
ARG DOWNLOAD_SERVER
ARG RES=/tmp/res

ENV NUI_NOTESDIR=/opt/domino
ENV NUI_NOTESDIR_DATA=/var/domino/data
ENV NUI_NOTESUSER=notes
ENV PATH=${NUI_NOTESDIR}/bin:$PATH

COPY util/functions_v9.sh $RES/functions.sh
COPY ${IMAGE_FOLDER}/resources/ $RES/

RUN apt-get update && apt-get install -y \
    cpio \
    gdb \
    nano \
    procps \
    rsync \
    screen \
    unzip \
    wget

RUN groupadd ${NUI_NOTESUSER} && \
    useradd -m -s /bin/sh -g ${NUI_NOTESUSER} ${NUI_NOTESUSER}

RUN mkdir -p $RES && cd $RES && \
    . ./functions.sh && \
    run_installer "BASE"

VOLUME ["/var/domino"]
EXPOSE 25 80 1352 63148

USER ${NUI_NOTESUSER}
WORKDIR ${NUI_NOTESDIR_DATA}

COPY util/docker-entrypoint.sh /
CMD ["/docker-entrypoint.sh"]
