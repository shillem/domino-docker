#!/bin/bash
NUI_NOTESDIR_SERVER=$NUI_NOTESDIR/bin/server

stop_server() {
    $NUI_NOTESDIR_SERVER -q
}

if [ -f "$NUI_NOTESDIR_DATA/server.id" ]; then
    trap "stop_server" HUP INT QUIT TERM

    screen -dmS console "$NUI_NOTESDIR_SERVER"

    echo "Run 'docker container exec -it <container> screen -r console' to access the server console."
    echo "Run 'docker container stop <container>' to stop the server."

    while [[ ! -z $(ps -ef | pgrep -f 'SCREEN \-dmS console') ]]; do
        sleep 1
    done
else
    $NUI_NOTESDIR_SERVER -listen 1352
fi
