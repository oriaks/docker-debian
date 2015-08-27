#!/bin/sh

_REPO='oriaks'

_usage () {
  cat <<- EOF
	Usage: $0 build   Build images
	       $0 shell   Invoke an interactive shell in a new ephemeral container

EOF
}

_DIR=`cd "$( dirname "$0" )" && pwd`
_CMD="$1"

[ -n "${_CMD}" ] && shift

case "${_CMD}" in
  "build")
    docker build --force-rm=true -t "${_REPO}/debootstrap:latest" debootstrap
    docker run -it --privileged --rm -v "${_DIR}/debian:/debian" "${_REPO}/debootstrap:latest"
    docker build --force-rm=true -t "${_REPO}/debian:latest" debian
    ;;
  "shell")
    docker run -it --rm "${_REPO}/debian:latest"
    ;;
  *)
    _usage
    ;;
esac
