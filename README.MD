# Domino Docker
This project contains the necessary scripts to build DEBIAN-BASED Domino server images.

**In order to build the images you must provide the Domino files used to install the server and any other eventual additional packages**.

## Image
Use `build.sh` to build the images. The script requires either 2 or 3 parameters:

1. image name (mandatory)
2. path containing the Dockerfile used for the build (mandatory)
3. parent image name (used when creating image based on a source image, e.g. to build 9.0.1.10 from 9.0.1)

The `version-base` folder contains the base versions of the images to be built.  
The `version-upgrade` folder contains the images that can be built on top of the base versions.  
The `version-custom` folder contains tweaked images bases either on the base or the upgrade versions.  

The first images to be built must be the ones coming from the `version-base` folder.
The images in `version-upgrade` and `version-custom` are in fact build of top of the `version-base` folder. For example, in order to build any 9.0.1.* version, the base 9.0.1 image must be built first.

### Options
Under each version's `resources` folder you might find a variable number of files used during installation.
For example `resources\server_response_default.dat` is used by the main version. If you prefer to specify different options simply make a copy of `server_response_default.dat` and name it `server_response.dat`. The script will then detect the customized file and then use that instead of the default one. This pattern of copying a default file and naming it accordingly can be followed anywhere you find resource files whose names contain `_default`.

### Download server
In order to save space when building each image the script will make use of a temporary web server container to serve any Domino file used during the installation.

The container will map any local folder set as `WEB_CONTAINER_VOLUME` variable. Such folder will be served as the web server root. **Set the variable before launching the script**.

The `url_path_default.txt` file contains the exact relative path the script will use to download the needed file. Again, if you need to specify a different path copy `url_path_default.txt` into `url_path.txt` and change any value there.

Not every file is mandatory. If you don't have or don't want to install a specific hotfix or pack you can set the `url_path.txt` variable to "" (e.g. `SEOS=`).

This is the list of variable currently used:

* `SERVER=`: mandatory (the pack to install the base version)
* `FP=`: optional (the pack to install a server fix pack)
* `HF=`: optional (the pack to install a server hotfix)
* `NTF=`: optional (the pack to deploy the upgraded templates)
* `PROTON=`: optional (the pack to install the Proton task)
* `SEOS=`: optional (the pack to install the Social Component)

### Build command examples
```
WEB_CONTAINER_VOLUME=~/Downloads/Domino/Server
./build.sh my-domino:9.0.1 version-base/9.0.1
./build.sh my-domino:9.0.1.10 version-upgrade/9.0.1.10 my-domino:9.0.1
./build.sh my-domino-custom:9.0.1.10 version-custom/any my-domino:9.0.1.10
```

## Container
Before running the container carefully review the parameters below. These parameters will improve the default behavior of the container you are to run.

* `-d` (the container will start detached. You can substitute this parameter with `-it` if you will but, apart from saying how you can attach to the console and how you should stop the container, you won't see much)
* `-h <hostname>` (the container will have this value as host name, which will be later read by Domino)
* `-e <timezone>` (the container's time zone)
* `-p <ports>` (any ports you want to map from the container)
* `-v <volume>:/var/domino` (hook to map the persistent data layer, within this folder you will find the usual `data` folder)
* `--stop-timeout <seconds>` (**important**, to give the container a longer shutdown time out thus allowing the server to stop gracefully rather than being killed after only 10 seconds)

### Run command example
```
docker container run -d \
    -h mydomino \
    -e TZ=Europe/Rome \
    -p 80:80 -p 1352:1352 -p 63148:63148 \
    -v my-domino-volume:/var/domino \
    --stop-timeout 60 \
    --name my-domino \
    my-domino:9.0.1.10
```

If the container points to a fresh new volume (the server hasn't been set up yet), the container will start the server in listening mode.  
Use the `Remote Server Setup` utility to connect to the server (**on port `1352`**) and complete the set up. Then restart the container.

### Console access
The container will launch the Domino server on a screen session named `console`.  
If you want to access and/or interact with the console type the following command:

```
docker container exec -it <container_name> screen -r console
```

Commands can be sent without interactively accessing the console by typing:

```
docker container exec -it <container_name> sh -c "server -c 'res t http'"
```
or
```
docker container exec -it <container_name> screen -x -X stuff "res t http\n"
```

Exiting the console by typing `exit` or `quit` will shut down the Domino server and consequently the container.
