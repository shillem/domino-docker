#!/bin/bash

DOM_EXEC=/opt/ibm/domino/bin/server

function shut_down() {
  sh $DOM_EXEC -q
}

trap shut_down SIGTERM

if [ -f "/var/ibm/domino/data/server.id" ]; then
  #service domino start
  sh $DOM_EXEC
else
  sh $DOM_EXEC -listen 1352
fi
