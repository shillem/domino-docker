FROM shillem/domino:9.0.1.8

COPY resources/ /tmp

RUN chmod +x /tmp/com.ibm.designer* && \
  mv /tmp/com.ibm.designer* /opt/ibm/domino/notes/latest/linux/osgi/shared/eclipse/plugins/ && \
  mv /tmp/java.pol /opt/ibm/domino/notes/latest/linux/jvm/lib/security/ && \
  chmod +x /tmp/start.sh

EXPOSE 80 1352

VOLUME ["/var/ibm/domino/data"]

USER notes
WORKDIR /var/ibm/domino/data

CMD ["/tmp/start.sh"]
