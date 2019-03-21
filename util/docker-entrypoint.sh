#!/bin/bash

stop_server() {
    $NUI_NOTESDIR/bin/server -q
}

stop_server_setup() {
    kill $(ps -ef | pgrep -f 'lotus.domino.setup.Wizard')
}

if [ -f "$NUI_NOTESDIR_DATA/server.id" ]; then
    trap "stop_server" HUP INT QUIT TERM

    screen -dmS console $NUI_NOTESDIR/bin/server

    echo "Run 'docker container exec -it <container> screen -r console' to access the server console."
    echo "Run 'docker container stop <container>' to stop the server."
else
    trap "stop_server_setup" HUP INT QUIT TERM

    screen -dmS console $NUI_NOTESDIR/bin/server -listen 1352

    echo "Run 'docker container exec -it <container> screen -r console' to access the server setup information."
    echo "Run 'docker container stop <container>' to stop the server setup."
fi

while [[ ! -z $(ps -ef | pgrep -f 'SCREEN \-dmS console') ]]; do
    sleep 1
done