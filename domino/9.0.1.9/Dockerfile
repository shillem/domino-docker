FROM shillem/domino:9.0.1

ENV DEBIAN_FRONTEND noninteractive

COPY resources/ /tmp/res

ENV NUI_NOTESDIR /opt/ibm/domino

RUN mkdir -p /tmp/res/ && \
  cd /tmp/res/ && \
  wget -q http://host.docker.internal:7777/Public/Binaries/IBM/Domino/Linux/domino901FP9_linux64_x86.tar && \
  tar -xf domino901FP9_linux64_x86.tar && \
  cd linux64/domino && \
  sed -i 's/defined(@{$scr->{target_hosts}})/@{$scr->{target_hosts}}/' tools/lib/NIC.pm && \
  bash -c "./install -script /tmp/res/fp_script.dat" && \
  rm -R /tmp/res/linux64/*

RUN cd /tmp/res/ && \
  wget -q http://host.docker.internal:7777/Public/Binaries/IBM/Domino/Linux/DOM_SEOS_COMPNT_901FP9_LINUX64.tar && \
  tar -xf DOM_SEOS_COMPNT_901FP9_LINUX64.tar && \
  cd linux64 && \
  chmod +x install && \
  bash -c "./install -silent -options /tmp/res/seos_response.dat"

RUN cd /tmp/res/ && \
  wget -q http://host.docker.internal:7777/Public/Binaries/IBM/Domino/ND_901FP9_EN_templates.zip && \
  unzip -o ND_901FP9_EN_templates.zip -d /var/ibm/domino/data && \
  chown -R notes.notes /var/ibm/domino/data

RUN rm -R /opt/ibm/domino/notes/latest/linux/data1_bck && rm -R /tmp/*