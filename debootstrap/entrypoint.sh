#!/bin/sh
#
#  Copyright (C) 2015 Michael Richard <michael.richard@oriaks.com>
#
#  This program is free software: you can redistribute it and/or modify
#  it under the terms of the GNU General Public License as published by
#  the Free Software Foundation, either version 2 of the License, or
#  (at your option) any later version.
#
#  This program is distributed in the hope that it will be useful,
#  but WITHOUT ANY WARRANTY; without even the implied warranty of
#  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#  GNU General Public License for more details.
#
#  You should have received a copy of the GNU General Public License
#  along with this program.  If not, see <http://www.gnu.org/licenses/>.
#

if [ -n "${DEBUG}" ]; then
  set -x
fi

_SUITE='jessie'

_TARGET="/var/tmp/${_SUITE}"
_ARCHIVE="/debian/debian-${_SUITE}.tar.xz"
_INCLUDE='inetutils-ping,iproute2'

DEBIAN_FRONTEND='noninteractive'
TERM='linux'

_in_target () {
  PATH='/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin' \
  chroot "${_TARGET}" "$@"

  return
}

_install () {
  [ -f /usr/sbin/debootstrap ] && return

  apt-get update -q
  apt-get install -y debootstrap xz-utils

  return 0
}

_init () {
  [ -d "${_TARGET}" ] || mkdir -p "${_TARGET}"

  debootstrap --variant="minbase" --include="${_INCLUDE}" "${_SUITE}" "${_TARGET}" "http://httpredir.debian.org/debian"

  install -D -o root -g root -m 0644 /dev/stdin "${_TARGET}/etc/apt/apt.conf.d/autoremove-suggests" <<- EOF
	Apt::AutoRemove::SuggestsImportant "false";
EOF

  install -D -o root -g root -m 0644 /dev/stdin "${_TARGET}/etc/apt/apt.conf.d/clean" <<- EOF
	DPkg::Post-Invoke { "rm -f /var/cache/apt/archives/*.deb /var/cache/apt/archives/partial/*.deb /var/cache/apt/*.bin || true"; };
	APT::Update::Post-Invoke { "rm -f /var/cache/apt/archives/*.deb /var/cache/apt/archives/partial/*.deb /var/cache/apt/*.bin || true"; };
	Dir::Cache::pkgcache "";
	Dir::Cache::srcpkgcache "";
EOF

  install -D -o root -g root -m 0644 /dev/stdin "${_TARGET}/etc/apt/apt.conf.d/gzip-indexes" <<- EOF
	Acquire::GzipIndexes "true";
	Acquire::CompressionTypes::Order:: "gz";
EOF

  install -D -o root -g root -m 0644 /dev/stdin "${_TARGET}/etc/apt/apt.conf.d/no-languages" <<- EOF
	Acquire::Languages "none";
EOF

  install -D -o root -g root -m 0644 /dev/stdin "${_TARGET}/etc/apt/apt.conf.d/periodic" <<- EOF
	APT::Periodic::Update-Package-Lists "0";
EOF

  install -D -o root -g root -m 0644 /dev/stdin "${_TARGET}/etc/apt/sources.list.d/security.list" <<- EOF
	deb http://security.debian.org ${_SUITE}/updates main
EOF

  if [ -d "${_TARGET}/etc/cloud" ]; then
    install -D -o root -g root -m 0644 /dev/stdin "${_TARGET}/etc/cloud/cloud.cfg.d/00_apt.cfg" <<- EOF
	apt_preserve_source_list: True
	apt_update: True
	apt_upgrade: True
EOF

    install -D -o root -g root -m 0644 /dev/stdin "${_TARGET}/etc/cloud/cloud.cfg.d/00_resizefs.cfg" <<- EOF
	resize_rootfs: True
EOF

    install -D -o root -g root -m 0644 /dev/stdin "${_TARGET}/etc/cloud/cloud.cfg.d/00_hosts.cfg" <<- EOF
	manage_etc_hosts: True
EOF

    install -D -o root -g root -m 0644 /dev/stdin "${_TARGET}/etc/cloud/cloud.cfg.d/90_dpkg.cfg" <<- EOF
	# to update this file, run dpkg-reconfigure cloud-init
	datasource_list: [ Ec2 ]
EOF
  fi

  if [ -f "${_TARGET}/etc/ssh/sshd_config" ]; then
    sed -ri -f- /target/etc/ssh/sshd_config <<- EOF
	s|^PermitRootLogin.*$|PermitRootLogin without-password|;
EOF
  fi

  install -D -o root -g root -m 0644 /dev/stdin "${_TARGET}/etc/dpkg/dpkg.cfg.d/apt-speedup" <<- EOF
	force-unsafe-io
EOF

  install -D -o root -g root -m 0644 /dev/stdin "${_TARGET}/etc/resolv.conf" <<- EOF
	nameserver 8.8.8.8
	nameserver 8.8.4.4
EOF

  install -D -o root -g root -m 0755 /dev/stdin "${_TARGET}/usr/sbin/policy-rc.d" <<- EOF
	#!/bin/sh
	exit 101
EOF

  mv "/klish_2.0.4_amd64.deb" "${_TARGET}/"
  _in_target dpkg -i /klish_2.0.4_amd64.deb
  _in_target apt-get install -fy
  rm -f "${_TARGET}/klish_2.0.4_amd64.deb"

  _in_target apt-get -q update
  _in_target apt-get -y dist-upgrade
  _in_target apt-get -y clean

  rm -fr "${_TARGET}/dev"/*
  rm -f  "${_TARGET}/etc/apt/apt.conf.d/01autoremove-kernels"
  rm -f  "${_TARGET}/etc/hostname"
  rm -f  "${_TARGET}/etc/ssh"/ssh_host_*
  rm -f  "${_TARGET}/etc/udev/rules.d/70-persistent-net.rules"
  rm -f  "${_TARGET}/lib/udev/write_net_rules"
  rm -f  "${_TARGET}/var/cache/apt"/*.bin
  rm -f  "${_TARGET}/var/cache/apt/archives"/*.deb
  rm -f  "${_TARGET}/var/cache/apt/archives/partial"/*.deb
  rm -fr "${_TARGET}/var/lib/apt/lists"/*

  [ -f "${_ARCHIVE}" ] && rm -f "${_ARCHIVE}"
  tar -cJf "${_ARCHIVE}" -C "${_TARGET}" .

  rm -rf "${_TARGET}"

  return 0
}

_usage () {
	cat <<- EOF
	Usage: $0 install  Install debootstrap
	       $0 init     Launch debootstrap
EOF

	return 0
}

_CMD="$1"
[ -n "${_CMD}" ] && shift

case "${_CMD}" in
  "install")
    _install $*
    ;;
  "init")
    _init $*
    ;;
  *)
    _usage
    ;;
esac
