FROM debian:latest

ENV DEBIAN_FRONTEND noninteractive

ARG IMAGE_FOLDER
ARG DOWNLOAD_SERVER
ARG RES=/tmp/res

ENV NUI_NOTESDIR=/opt/domino
ENV NUI_NOTESDIR_DATA=/var/domino/data
ENV NUI_NOTESUSER=notes
ENV PATH=${NUI_NOTESDIR}/bin:$PATH

COPY util/functions.sh $RES/
COPY ${IMAGE_FOLDER}/resources/ $RES/

RUN apt-get update && apt-get install -y \
    bc \
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
    DOWNLOAD_FILE=$(get_file_property "url_path_default.txt" "SERVER") && \
    wget -q ${DOWNLOAD_SERVER}/$DOWNLOAD_FILE && \
    tar -xf $(basename $DOWNLOAD_FILE) && \
    cd linux64/domino && \
    bash -c "./install -silent -options $(prepare_config_file $RES/server_response_default.dat)" && \
    cd $RES && rm -R linux64 && rm $(basename $DOWNLOAD_FILE)

RUN cd $RES && \
    . ./functions.sh && \
    DOWNLOAD_FILE=$(get_file_property "url_path_default.txt" "PROTON") && [ ! -z "$DOWNLOAD_FILE" ] && \
    wget -q ${DOWNLOAD_SERVER}/$DOWNLOAD_FILE && \
    mkdir proton && tar -xf $(basename $DOWNLOAD_FILE) -C proton && \
    mkdir proton-addin && tar -xzf proton/proton-addin-*.tgz -C proton-addin && \
    chmod u=rwx,g=rx,o=rx proton-addin/* && mv proton-addin/* ${NUI_NOTESDIR}/notes/latest/linux && \
    rm -R proton && rm -R proton-addin && rm $(basename $DOWNLOAD_FILE)

VOLUME ["/var/domino"]
EXPOSE 25 80 1352 3002 63148

USER ${NUI_NOTESUSER}
WORKDIR ${NUI_NOTESDIR_DATA}

COPY util/docker-entrypoint.sh /
CMD ["/docker-entrypoint.sh"]
