#!/bin/sh

_REPO='oriaks'
_DIR=`cd "$( dirname "$0" )" && pwd`

docker run -it --rm "${_REPO}/debian:latest"
