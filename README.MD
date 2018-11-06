# Docker commands to create Domino images from scratch

## Create and run nginx container to build domino images later on
```
docker container run --name software -d /
    -p 7777:80 /
    -v ~/Dropbox:/usr/share/nginx/html:ro /
    nginx
```

## Build images
```
docker image build -t shillem/domino:9.0.1 .
docker image build -t shillem/domino:9.0.1.10 .
docker image build -t shillem/domino-ready:9.0.1.10 .
```

## Create and run container from the domino image
```
docker container run --name powerplant -it /
    -h powerplant.springfield.local /
    -e TZ=Europe/Rome /
    -p 80:80 -p 1352:1352 /
    -v ~/Documents/Docker/volumes/powerplant/domino:/var/ibm/domino /
    shillem/domino-ready:9.0.1.10
```

## To run domino while overriding the entry point
```
docker container run --name v90110 -it /
    -v ~/Documents/Docker/volumes/powerplant/domino:/mnt /
    shillem/domino-ready:9.0.1.10 /
    bash
```

## To upgrade the existing data through some patching
```
docker container run --name v90110 -it /
    -v ~/Documents/Docker/volumes/powerplant/domino:/mnt /
    shillem/domino:9.0.1.10 /
    bash
```

# Docker commands to create mongo instance
```
docker container run --name hello-mongo -d /
    -p 27017:27017 /
    -v ~/Documents/Docker/volumes/hello-mongo:/data/db /
    mongo
```