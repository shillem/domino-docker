ARG FROM_DOMINO_IMAGE
FROM ${FROM_DOMINO_IMAGE}

ARG IMAGE_FOLDER
ARG DOWNLOAD_SERVER
ARG RES=/tmp/res

USER root

COPY ${IMAGE_FOLDER}/resources/ $RES/

RUN cd $RES && \
    . ./functions.sh && \
    DOWNLOAD_FILE=$(get_file_property "url_path_default.txt" "FP") && [ ! -z "$DOWNLOAD_FILE" ] && \
    wget -q ${DOWNLOAD_SERVER}/$DOWNLOAD_FILE && \
    tar -xf *.tar && \
    cd linux64/domino && \
    fix_setup_file "tools/lib/NIC.pm" && \
    bash -c "./install -script $(prepare_config_file $RES/fp_script_default.dat)" && \
    cd $RES && rm -R linux64 && rm *.tar

RUN cd $RES && \
    . ./functions.sh && \
    DOWNLOAD_FILE=$(get_file_property "url_path_default.txt" "SEOS") && [ ! -z "$DOWNLOAD_FILE" ] && \
    wget -q ${DOWNLOAD_SERVER}/$DOWNLOAD_FILE && \
    tar -xf *.tar && \
    cd linux64 && \
    chmod +x install && \
    bash -c "./install -silent -options $(prepare_config_file $RES/seos_response_default.dat)" && \
    cd $RES && rm -R linux64 && rm *.tar

RUN cd $RES && \
    . ./functions.sh && \
    DOWNLOAD_FILE=$(get_file_property "url_path_default.txt" "HF") && [ ! -z "$DOWNLOAD_FILE" ] && \
    wget -q ${DOWNLOAD_SERVER}/$DOWNLOAD_FILE && \
    tar -xf *.tar && \
    cd linux64 && \
    fix_setup_file "tools/lib/NIC.pm" && \
    bash -c "./install -script $(prepare_config_file $RES/hf_script_default.dat)" && \
    cd $RES && rm -R linux64 && rm *.tar

RUN cd $RES && \
    . ./functions.sh && \
    DOWNLOAD_FILE=$(get_file_property "url_path_default.txt" "NTF") && [ ! -z "$DOWNLOAD_FILE" ] && \
    wget -q ${DOWNLOAD_SERVER}/$DOWNLOAD_FILE && \
    unzip -o *.zip -d ${NUI_NOTESDIR_DATA} && \
    chown -R ${NUI_NOTESUSER}.${NUI_NOTESUSER} ${NUI_NOTESDIR_DATA} && \
    rm *.zip

RUN rm -R $NUI_NOTESDIR/notes/latest/linux/data1_bck

USER ${NUI_NOTESUSER}