ARG FROM_DOMINO_IMAGE
FROM ${FROM_DOMINO_IMAGE}

ARG IMAGE_FOLDER
ARG DOWNLOAD_SERVER
ARG RES=/tmp/res

USER root

COPY ${IMAGE_FOLDER}/resources/ $RES/

RUN cd $RES && \
    . ./functions.sh && \
    run_installer "FP"

RUN rm -R $NUI_NOTESDIR/notes/latest/linux/data1_bck

USER ${NUI_NOTESUSER}