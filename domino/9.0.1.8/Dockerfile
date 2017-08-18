FROM shillem/domino:9.0.1

ENV DEBIAN_FRONTEND noninteractive

COPY resources/ /tmp/res

ENV NUI_NOTESDIR /opt/ibm/domino

RUN mkdir -p /tmp/res/ && \
  cd /tmp/res/ && \
  wget -q http://172.17.0.1:7777/Public/Binaries/IBM/Domino/Linux/domino901FP8_linux64_x86.tar && \
  tar -xf domino901FP8_linux64_x86.tar && \
  cd linux64/domino && \
  bash -c "./install -script /tmp/res/fp_script.dat" && \
  rm -R /tmp/res/linux64/*

RUN cd /tmp/res/ && \
  wget -q http://172.17.0.1:7777/Public/Binaries/IBM/Domino/Linux/DOM_SEOS_COMPNT_901FP8_LINUX64.tar && \
  tar -xf DOM_SEOS_COMPNT_901FP8_LINUX64.tar && \
  cd linux64 && \
  chmod +x install && \
  bash -c "./install -silent -options /tmp/res/seos_response.dat"

RUN cd /tmp/res/ && \
  wget -q http://172.17.0.1:7777/Public/Binaries/IBM/Domino/Linux/901FP8HF240-linux64.tar && \
  tar -xf 901FP8HF240-linux64.tar && \
  cd linux64 && \
  bash -c "./install -script /tmp/res/fp_script.dat" && \
  rm -R /tmp/res/linux64/*

RUN cd /tmp/res/ && \
  chown notes.notes *.ntf && mv *.ntf /var/ibm/domino/data

RUN rm -R /opt/ibm/domino/notes/latest/linux/data1_bck && rm -R /tmp/*
