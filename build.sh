#!/bin/sh

_REPO='oriaks'
_DIR=`cd "$( dirname "$0" )" && pwd`

docker build --force-rm=true -t "${_REPO}/debootstrap:latest" debootstrap
docker run -it --privileged --rm -v "${_DIR}/debian:/debian" "${_REPO}/debootstrap:latest"
docker build --force-rm=true -t "${_REPO}/debian:latest" debian
