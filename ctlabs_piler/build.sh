#!/bin/bash

# ------------------------------------------------------------------------------
# SOURCES
# ------------------------------------------------------------------------------
VERSION=1.4.8
NAME=piler

SRC_TAR=${NAME}-${VERSION}.tar.gz
SRC_URL="https://github.com/jsuto/piler/archive/refs/tags/${NAME}-${VERSION}.tar.gz"

# ------------------------------------------------------------------------------
# Package Attributes
# ------------------------------------------------------------------------------
DESC="mail archive search engine"
URL=https://github.com/jsuto/piler
PKG_NAME=ctlabs_${NAME}
DEB_NAME=ctlabs_${NAME}-${VERSION}.amd64.deb
BUILD_DEPS=(gcc make libssl-dev libtre-dev libcurl4-openssl-dev zlib1g-dev libmariadb-dev)
RUNTIME_DEPS=(openssl libtre5 libcurl4 mariadb-client)

# ------------------------------------------------------------------------------
# Build Details
# ------------------------------------------------------------------------------
SRCDIR=${NAME}-${NAME}-${VERSION}
DSTDIR=/tmp/${NAME}-build

# ------------------------------------------------------------------------------
# Build Functions
# ------------------------------------------------------------------------------
prepare() {
  mkdir -vp /tmp/${NAME}
  cd /tmp/${NAME} && curl -sLO ${SRC_URL} && tar xzf ${SRC_TAR}
  cd -
}

install_build_deps() {
  apt-get update -qq
  apt-get install -y -qq ${BUILD_DEPS[@]}
}

build() {
  cd /tmp/${NAME}/${SRCDIR}

  ./configure                        \
    --prefix=/usr                    \
    --sysconfdir=/etc                \
    --localstatedir=/var

  make -j$(nproc)
  make install DESTDIR=${DSTDIR}

  cd -
}

build_deb() {
  fpm -s dir                    \
      -t deb                    \
      -p ${DEB_NAME}            \
      -n ${PKG_NAME}            \
      -v ${VERSION}             \
      -a amd64                  \
      --url ${URL}              \
      --description "${DESC}"   \
      -C ${DSTDIR}              \
      --deb-no-default-config-files \
      -d 'libmariadb3'          \
      -d 'libtre5'              \
      -d 'libzip4'              \
      -d 'libcurl4'             \
      -d 'openssl'              \
      -d 'zlib1g'               \
      .
}

cleanup() {
  rm -rf /tmp/${NAME}
  rm -rf ${DSTDIR}
}

prepare
install_build_deps
build
build_deb
cleanup
