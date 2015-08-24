#!/bin/sh

_usage () {
  cat <<- EOF
	Usage: $0 build   Build images

EOF
}

_DIR=`cd "$( dirname "$0" )" && pwd`
_CMD="$1"

[ -n "${_CMD}" ] && shift

case "${_CMD}" in
  "build")
    docker build --force-rm=true -t oriaks/debootstrap:latest debootstrap
    docker run -it --cap-add sys_admin --rm -v "${_DIR}/debian:/debian" oriaks/debootstrap:latest
    docker build --force-rm=true -t oriaks/debian:latest debian
    ;;
  "shell")
    docker run -it --rm oriaks/debian:latest
    ;;
  *)
    _usage
    ;;
esac
