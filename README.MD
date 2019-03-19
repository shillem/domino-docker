## Build
Use `build.sh` to build the images. The script requires 2 parameters:

1. image prefix name
2. image name
3. image version

These parameters choice **must** reflect the folder structure of the current project. In other words the folder names correspond to the names that must be used as image name. Each folder must container a subfolder whose name can represent the image version.

e.g. considered the current project's folders:

* domino/9.0.1
* domino/9.0.1.10

the corresponding commands `./build.sh shillem domino 9.0.1` and `./build.sh shillem domino 9.0.1.10 shillem-domino:9.0.1` will generate the following images:

* shillem-domino:9.0.1
* shillem-domino:9.0.1.10

### All the commands:
```
./build.sh shillem domino 9.0.1 && \
./build.sh shillem domino 9.0.1.10 shillem-domino:9.0.1 && \
./build.sh shillem domino-ready 9.0.1.10 shillem-domino:9.0.1.10
```

## Container
```
docker container run -d \
    -h powerplant.springfield.local \
    -e TZ=Europe/Rome \
    -p 80:80 -p 1352:1352 -p 63148:63148 \
    -v ~/Docker/volumes/powerplant/domino:/var/domino \
    --stop-timeout 60 \
    --name powerplant \
    shillem-domino-ready:9.0.1.10
```
