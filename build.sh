#!/bin/bash
set -e

if [ -z "$1" ]; then
    echo "You must specify the image prefix name"
    exit 0
fi

DOCKER_IMAGE_PREFIX_NAME=$1

if [ -z "$2" ]; then
    echo "You must specify the docker prefix image name"
    exit 0
fi

DOCKER_IMAGE_NAME=$2

if [ -z "$3" ]; then
    echo "You must specify the image version (must correspond to a current path's subfolder)"
    exit 0
fi

DOCKER_IMAGE_VERSION=$3

DOCKER_IMAGE=$DOCKER_IMAGE_PREFIX_NAME-$DOCKER_IMAGE_NAME:$DOCKER_IMAGE_VERSION

NGINX_CONTAINER_NAME=ibm-software
NGINX_CONTAINER_VOLUME=~/Dropbox/Work/IBM/Domino

docker container run --rm -d \
    -v $NGINX_CONTAINER_VOLUME:/usr/share/nginx/html:ro \
    --name $NGINX_CONTAINER_NAME \
    nginx


cd $2/$3
{
    NGINX_IP=$(docker container inspect $NGINX_CONTAINER_NAME --format "{{.NetworkSettings.IPAddress}}")

    if [ -z "$4" ]; then
        docker image build -t $DOCKER_IMAGE \
            --build-arg DOWNLOAD_SERVER=http://$NGINX_IP \
            .
    else
        docker image build -t $DOCKER_IMAGE \
            --build-arg DOWNLOAD_SERVER=http://$NGINX_IP \
            --build-arg FROM_DOMINO_IMAGE=$4 \
            .
    fi
} || {
    echo "An error occurred"
}

docker container stop $NGINX_CONTAINER_NAME