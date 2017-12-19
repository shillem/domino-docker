FROM shillem/domino:9.0.1.9

COPY resources/ /tmp

RUN mv /tmp/java.pol /opt/ibm/domino/notes/latest/linux/jvm/lib/security/ && \
  chmod +x /tmp/start.sh

EXPOSE 80 1352

VOLUME ["/var/ibm/domino/data"]

USER notes
WORKDIR /var/ibm/domino/data

CMD ["/tmp/start.sh"]
