# Image
This project contains the necessary scripts to build Domino server images (Debian based).

**In order to build the images  you must provide the binaries used to install the server and any eventual additional packs**.

## Build
Use `build.sh` to build the images. The script requires either 2 or 3 parameters:

1. image name (mandatory)
2. path containing the Dockerfile used for the build (mandatory)
3. parent image name (optional, used only when creating FP based builds)

Under the `vanilla` folder, subfolders identify the versions of the images to be built.  
Images must be built in the proper order. For example, in order to build any 9.0.1.* version, the basic 9.0.1 image must be built first (and then used as third parameter when calling `build.sh`).

### Options
Under each version's `resources` folder you might find a variable number of files used during installation.
For example `resources\server_response_default.dat` is used by the main version. If you prefer to specify different options simply make a copy of `server_response_default.dat` and name it `server_response.dat`. The script will then detect the customized file and use that instead of the default one. This pattern of copying a default file can be followed anywhere you find resource files whose names contain `_default`.

### Download server
In order to efficiently build each image the script will make use of a temporary web server container to serve the files used during the installation.

The container will map the any local folder served by the `WEB_CONTAINER_VOLUME` variable that will be used as the web server root. Before launching the script is then necessary to set such variable.

The `url_path_default.txt` file contains the exact file that the script will download in order to install the server/fix pack/hot fix etc. Again, if you need to specify a different file name or structured path copy `url_path_default.txt` and name it `url_path.txt`.

## Build commands example
```
WEB_CONTAINER_VOLUME=~/Downloads/Domino/Server
./build.sh vanilla-domino:9.0.1 vanilla/9.0.1
./build.sh vanilla-domino:9.0.1.10 vanilla/9.0.1.10 vanilla-domino:9.0.1
./build.sh my-domino:9.0.1.10 custom/9.0.1.10 vanilla-domino:9.0.1.10
```

## Container
To run a container from any of the built image make sure to specify some useful default parameters.

* `-d` (the container will start detached, you can substitute this parameter with `-it` if you will but apart from saying how to attach to the console and stop the container you won't see much else)
* `-h \<hostname\>` (the container will have this value as host name, which will be read by Domino)
* `-e \<timezone\>` (the container time zone)
* `-p \<ports\>` (any ports you want to map from the container)
* `-v \<volume\>:/var/domino` (hook to map the persistent data layer, within this folder `data` will contains the databases etc..)
* `--stop-timeout <seconds>` (important to allow the container to stop gracefully before Docker decides to kill it)

### Run command example
```
docker container run -d \
    -h mydomino.mydomain.local \
    -e TZ=Europe/Rome \
    -p 80:80 -p 1352:1352 -p 63148:63148 \
    -v my-domino-volume:/var/domino \
    --stop-timeout 60 \
    --name my-domino \
    my-domino:9.0.1.10
```

If the container points to a fresh new volume (the server hasn't been set up yet), the container will start the server in listening mode.  
Use the `Remote Server Setup` utility to connect to the server (**on port `1352`**) and complete the set up.

### Console access
The container will launch the Domino server on a screen session named `console`.  
If you want to access and/or interact with the console type the following command:

```
docker container exec -it <container_name> screen -r console
```
Exiting the console by typing of `exit` or `quit` will shut down the Domino server and consequently the container.