docker commmands for building the images

docker run -p 7777:80 -v /Users/shillem/Dropbox:/usr/share/nginx/html:ro -d --name software nginx

docker build -t shillem/domino:9.0.1 .
docker build -t shillem/domino:9.0.1.9 .
docker build -t shillem/domino-ready:9.0.1.9 .

docker run -it -e TZ=Europe/Rome -p 1352:1352 -p 80:80 -v /Users/shillem/Documents/Docker/data/powerplant/data:/var/ibm/domino/data:cached --name powerplant shillem/domino-ready:9.0.1.9