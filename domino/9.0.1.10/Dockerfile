ARG FROM_DOMINO_IMAGE
FROM ${FROM_DOMINO_IMAGE}

ARG DOWNLOAD_SERVER
ARG RES=/tmp/res

USER root

COPY resources/ $RES/

RUN cd $RES && \
    wget -q ${DOWNLOAD_SERVER}/Linux/domino901FP10_linux64_x86.tar && \
    tar -xf *.tar && \
    cd linux64/domino && \
    sed -i 's/defined(@{$scr->{target_hosts}})/@{$scr->{target_hosts}}/' tools/lib/NIC.pm && \
    bash -c "./install -script ${RES}/fp_script.dat" && \
    cd $RES && rm -R linux64 && rm *.tar

RUN cd $RES && \
    sed -i "s|-P installLocation=\".*\"|-P installLocation=\"$NUI_NOTESDIR\"|" seos_response.dat && \
    sed -i "s|-W normalData.installLocationData=\".*\"|-W normalData.installLocationData=\"$NUI_NOTESDIR_DATA\"|" seos_response.dat && \
    sed -i "s|-W NameUserGroupPanel.UserName=\".*\"|-W NameUserGroupPanel.UserName=\"$NUI_NOTESUSER\"|" seos_response.dat && \
    sed -i "s|-W NameUserGroupPanel.GroupName=\".*\"|-W NameUserGroupPanel.GroupName=\"$NUI_NOTESUSER\"|" seos_response.dat && \
    wget -q ${DOWNLOAD_SERVER}/Linux/DOM_SEOS_COMPNT_901FP10_LINUX64.tar && \
    tar -xf *.tar && \
    cd linux64 && \
    chmod +x install && \
    bash -c "./install -silent -options ${RES}/seos_response.dat" && \
    cd $RES && rm -R linux64 && rm *.tar

RUN cd $RES && \
    wget -q ${DOWNLOAD_SERVER}/Linux/901FP10HF382-linux64.tar && \
    tar -xf *.tar && \
    cd linux64 && \
    sed -i 's/defined(@{$scr->{target_hosts}})/@{$scr->{target_hosts}}/' tools/lib/NIC.pm && \
    bash -c "./install -script ${RES}/fp_script.dat" && \
    cd $RES && rm -R linux64 && rm *.tar

RUN cd $RES && \
    wget -q ${DOWNLOAD_SERVER}/ND_901FP9_EN_templates.zip && \
    unzip -o ND_901FP9_EN_templates.zip -d ${NUI_NOTESDIR_DATA} && \
    chown -R ${NUI_NOTESUSER}.${NUI_NOTESUSER} ${NUI_NOTESDIR_DATA}

RUN rm -R $NUI_NOTESDIR/notes/latest/linux/data1_bck && rm -R $RES

USER ${NUI_NOTESUSER}