#!/bin/sh

DISTFILES=distfiles

if ! [ -d "${DISTFILES}" ]; then
	mkdir ${DISTFILES}
fi

if [ -z "${VERSION}" ]; then
VERSION=2.0.24
fi

DISTFILE=inspircd-${VERSION}.tar.gz
DISTFILE_EXTRA=inspircd-extras-*.tar.gz

check_errors() {
	if [ $? -ne 0 ]; then
		echo error
		exit 125
	fi
}

# do-extract

rm -rf inspircd-*

tar -xf ${DISTFILES}/${DISTFILE}

tar -xf ${DISTFILES}/${DISTFILE_EXTRA}
cp -pR inspircd-extras-*/2.0/* inspircd-${VERSION}/src/modules/extra

check_errors
