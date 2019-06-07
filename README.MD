# Domino Docker
This project contains the necessary scripts to build DEBIAN-BASED Domino server images.

**In order to build the images you must provide the Domino files used to install the server and any other eventual additional pack**.

## Image
Use `build.sh` to build the images. The script requires either 2 or 3 parameters:

1. image name (**mandatory**)
2. path containing the Dockerfile used for the build (**mandatory**)
3. parent image name (absent for `version-base` images, mandatory for `version-upgrade` and `version-custom` images)

#### `version-base`
This folder contains the base versions of the images to be built. **They are the first to be built**.

#### `version-upgrade`
This folder contains the images that can be built on top of the `version-base` images.

#### `version-custom`
This folder is present mainly as an example of how a furtherly tweaked image could be created.  
In `version-custom/any/resources` there's a `java.pol` file that will be deployed in the correct folder thus lifting any Java restriction coming with the default installation.  
The `Dockerfile` could also extend the ports that are exposed by default (`25 80 1352 63148` for Domino 9, and `25 80 1352 3002 63148` for Domino 10). Possibilities are endless...   
`version-custom` images are built on top of either `version-base` or `version-custom` images.

### Options
Under each version's `resources` folder you might find a variable number of files that will be used during the installation.
`*_default.dat` files are used to provide a standard behaviour. However custom behaviour can be defined by copying any `*_default.dat` file into a new file with the same name but stripped of the suffix (e.g. `server_response_default.dat` into `server_response.dat`). The script will then detect the custom file and then use that one instead of the `_default` one.

### Download server
In order to save space when building the images the script uses a disposable web server to pull the Domino files that will be used during the installation. There are 2 ways to make use of it properly:

1. The script will run a temporary web container and serve the installation files from your local disk by mapping your local folder as the web container root. To enable this mode set the `WEB_CONTAINER_VOLUME` variable to your local path (e.g. `export WEB_CONTAINER_VOLUME=~/Dropbox/Work/Domino/Server`).
2. The script will access an existing web server. To enable this mode set the `WEB_SERVER_URL` variable to your web server URL (e.g. `export WEB_SERVER_URL=http://mywebserver:8080`).

**Make sure to set either variable before running the script!**

The various `url_path_default.txt` files may contain a variable number of properties that hold the relative paths of the packs used during the process (e.g. `BASE=DOMINO_9.0.1_64_BIT_LIN_XS_EN.tar`). If a different path, or file name, needs to be specified a copy of `url_path_default.txt` to `url_path.txt` can be made and any different value can be changed, or cleared (in case you want to skip the installation of a specific pack, e.g. `SEOS=`).

This is the list of properties currently used:

* `BASE=`: the server (**mandatory**)
* `FP=`: the Fix Pack (optional)
* `HF=`: the Hotfix (optional)
* `NTF=`: the latest templates (optional)
* `PROTON=`: the AppDev pack (optional)
* `SEOS=`: the Social Component (optional)

### Build command examples
```
$ export WEB_CONTAINER_VOLUME=~/Downloads/Domino/Server
$ ./build.sh my-domino:9.0.1 version-base/9.x
$ ./build.sh my-domino:9.0.1.10 version-upgrade/9.x my-domino:9.0.1
$ ./build.sh my-domino-custom:9.0.1.10 version-custom/any my-domino:9.0.1.10
```
or
```
$ export WEB_CONTAINER_VOLUME=~/Downloads/Domino/Server
$ ./build.sh my-domino:10.0.1 version-base/10.x
$ ./build.sh my-domino:10.0.1.2 version-upgrade/10.x my-domino:10.0.1
$ ./build.sh my-domino-custom:10.0.1.2 version-custom/any my-domino:10.0.1.2
```

## Container
Before running the container carefully review the parameters below. These parameters will improve the default behavior of the container you run.

* `-d` (the container will start detached. You can substitute this parameter with `-it` if you will but, apart from saying how you can attach to the console and how you should stop the container, you will see nothing else)
* `-h <hostname>` (the container will have this value as host name, which will be later read by Domino)
* `-e TZ=<timezone>` (the container's time zone)
* `-p <ports>` (any ports you want to map from the container)
* `-v <volume>:/var/domino` (hook to map the persistent data layer, within this folder is positioned the `data` folder)
* `--stop-timeout <seconds>` (**important**, to give the container a longer shutdown time out thus allowing the server to stop gracefully rather than being killed after only 10 seconds)

### Run command example
```
$ docker container run -d \
    -h mydomino \
    -e TZ=Europe/Rome \
    -p 80:80 -p 1352:1352 -p 63148:63148 \
    -v my-domino-volume:/var/domino \
    --stop-timeout 60 \
    --name my-domino \
    my-domino:9.0.1.10
```
or
```
$ docker container run -d \
    -h mydomino \
    -e TZ=Europe/Rome \
    -p 80:80 -p 1352:1352 -p 3002:3002 \
    -v my-domino-volume:/var/domino \
    --stop-timeout 60 \
    --name my-domino \
    my-domino:10.0.1.2
```

If the container points to a fresh new volume (the server hasn't been set up yet), the container will start the server in listening mode.  
Use the `Remote Server Setup` utility to connect to the server (**on port `1352`**) and complete the setup, then restart the container.

### Console access
The container will launch the Domino server on a screen session named `console`.  
If you want to access and/or interact with the console type the following command:

```
$ docker container exec -it <container_name> screen -r console
```

Press `Ctrl + A` and then `D` to detach from the console.

Commands can be sent without interactively accessing the console by typing:

```
$ docker container exec -it <container_name> sh -c "server -c 'res t http'"
```
or
```
$ docker container exec -it <container_name> screen -x -X stuff "res t http\n"
```

Exiting the console by typing `exit` or `quit` will shut down the Domino server and consequently the container.

## Upgrade
When images get built they never work on existing volumes. That means that switching your container from Domino 9 to 10 won't upgrade your existing `data` folder files. The upgrade must be handled manually. One way to do this is to run a temporary new container while mapping your existing `var/domino` volume on a different folder of the said container. The container will therefore run with a fresh new `data` folder while also having access to your existing one. At this point you can run a `rsync` command to align the 2 `data` folders.

Consider the following command that performs a sync (copy new files and update existing with newer version if present) of the newer Domino 10 `data` folder onto a hypothetical Domino 9 `data` folder:

```
$ docker container run --rm -it -u 0 \
    -v my-domino-volume:/tmp/res \
    my-domino:10.0.2 \
    rsync -au --exclude="notes.ini" /var/domino/data/ /tmp/res/data/
```

After the process is ended the container, along with its volume, will be automatically discarded (because of the `--rm` switch).

**Note**: For a cleaner upgrade, you might want to consider stripping your current `data` folder of all the files you won't need because they will anyway be copied again by `rsync`.
