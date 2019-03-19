FROM debian:latest

ENV DEBIAN_FRONTEND noninteractive

ARG DOWNLOAD_SERVER
ARG RES=/tmp/res

ENV NUI_NOTESDIR=/opt/domino
ENV NUI_NOTESDIR_DATA=/var/domino/data
ENV NUI_NOTESUSER=notes

COPY resources/ $RES/

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
    sed -i "s|-P installLocation=\".*\"|-P installLocation=\"$NUI_NOTESDIR\"|" unix_response.dat && \
    sed -i "s|-W normalData.installLocationData=\".*\"|-W normalData.installLocationData=\"$NUI_NOTESDIR_DATA\"|" unix_response.dat && \
    sed -i "s|-W NameUserGroupPanel.UserName=\".*\"|-W NameUserGroupPanel.UserName=\"$NUI_NOTESUSER\"|" unix_response.dat && \
    sed -i "s|-W NameUserGroupPanel.GroupName=\".*\"|-W NameUserGroupPanel.GroupName=\"$NUI_NOTESUSER\"|" unix_response.dat && \
    wget -q ${DOWNLOAD_SERVER}/Linux/DOMINO_9.0.1_64_BIT_LIN_XS_EN.tar && \
    tar -xf *.tar && \
    cd linux64/domino && \
    bash -c "./install -silent -options ${RES}/unix_response.dat" && \
    cd / && \
    rm -R $RES

VOLUME ["/var/domino"]
EXPOSE 25 80 1352 63148

USER ${NUI_NOTESUSER}
WORKDIR ${NUI_NOTESDIR_DATA}

COPY ./docker-entrypoint.sh /
CMD ["/docker-entrypoint.sh"]
