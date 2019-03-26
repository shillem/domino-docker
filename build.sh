#!/bin/bash
set -e

if [ -z "$1" ]; then
    echo "You must specify the image name"
    exit 0
fi

DOCKER_IMAGE_NAME=$1

if [ -z "$2" ]; then
    echo "You must specify the Dockerfile folder name"
    exit 0
fi

DOCKER_IMAGE_BUILD_FOLDER=$2

if [ ! -d $DOCKER_IMAGE_BUILD_FOLDER ]; then
    echo "Dockerfile folder name does not exist"
    exit 0
fi

if [ -z "$WEB_CONTAINER_VOLUME" ]; then
    WEB_CONTAINER_VOLUME=~/Dropbox/Work/Domino/Server

    if [ ! -d $WEB_CONTAINER_VOLUME ]; then
        echo "You must set the WEB_CONTAINER_VOLUME variable. This folder should contain your Domino installation files"
        exit 0
    fi
fi

WEB_CONTAINER_NAME=ibm-software

docker container run --rm -d \
    -v $WEB_CONTAINER_VOLUME:/usr/share/nginx/html:ro \
    --name $WEB_CONTAINER_NAME \
    nginx:alpine \
    > /dev/null

{
    WEB_IP=$(docker container inspect $WEB_CONTAINER_NAME --format "{{.NetworkSettings.IPAddress}}")

    cmd="docker image build -f $DOCKER_IMAGE_BUILD_FOLDER/Dockerfile -t $DOCKER_IMAGE_NAME \
        --build-arg IMAGE_FOLDER=$DOCKER_IMAGE_BUILD_FOLDER \
        --build-arg DOWNLOAD_SERVER=http://$WEB_IP"

    if [ ! -z "$3" ]; then
        cmd+=" --build-arg FROM_DOMINO_IMAGE=$3"
    fi

    eval "$cmd ."
} || {
    echo "An error occurred"
}

docker container stop $WEB_CONTAINER_NAME > /dev/null