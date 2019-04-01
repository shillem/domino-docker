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

if [ ! -z "$WEB_SERVER_URL" ]; then
    echo "Using web server $WEB_SERVER_URL"

    WEB_CONTAINER_NAME=
elif [ ! -z "$WEB_CONTAINER_VOLUME" ]; then
    WEB_CONTAINER_NAME=ibm-software
    
    echo "Using web container $WEB_CONTAINER_NAME with root set on $WEB_CONTAINER_VOLUME"

    docker container run --rm -d \
        -v $WEB_CONTAINER_VOLUME:/usr/share/nginx/html:ro \
        --name $WEB_CONTAINER_NAME \
        nginx:alpine \
        > /dev/null
else 
    echo "You must set the either the WEB_SERVER_URL or WEB_CONTAINER_VOLUME variable"
    exit 0
fi

{
    if [ -z "$WEB_SERVER_URL" ]; then
        WEB_CONTAINER_IP=$(docker container inspect $WEB_CONTAINER_NAME --format "{{.NetworkSettings.IPAddress}}")
        WEB_SERVER_URL=http://$WEB_CONTAINER_IP
    fi

    cmd="docker image build -f $DOCKER_IMAGE_BUILD_FOLDER/Dockerfile -t $DOCKER_IMAGE_NAME \
        --build-arg IMAGE_FOLDER=$DOCKER_IMAGE_BUILD_FOLDER \
        --build-arg DOWNLOAD_SERVER=$WEB_SERVER_URL"

    if [ ! -z "$3" ]; then
        cmd+=" --build-arg FROM_DOMINO_IMAGE=$3"
    fi

    eval "$cmd ."
} || {
    echo "An error occurred"
}

if [ ! -z "$WEB_CONTAINER_NAME" ]; then
    docker container stop $WEB_CONTAINER_NAME > /dev/null
fi