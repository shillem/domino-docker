# Docker commands to create Domino images from scratch

## Create and run nginx container to build domino images later on
```
docker run -p 7777:80 -v /Users/shillem/Dropbox:/usr/share/nginx/html:ro -d --name software nginx
```

## Build images
```
docker build -t shillem/domino:9.0.1 .
docker build -t shillem/domino:9.0.1.9 .
docker build -t shillem/domino-ready:9.0.1.9 .
```

## Create and run container from the domino image
```
docker run -it -h powerplant.springfield.local -e TZ=Europe/Rome -p 1352:1352 -p 80:80 -v /Users/shillem/Documents/Docker/data/powerplant/data:/var/ibm/domino/data:cached --name powerplant shillem/domino-ready:9.0.1.9
```

## To run domino while overriding the entry point
```
docker run -it -v /Users/shillem/Documents/Docker/data/powerplant/data:/mnt --entrypoint "/bin/bash" --name v9019 shillem/domino-ready:9.0.1.9
```