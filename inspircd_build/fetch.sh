#!/bin/sh

DISTFILES=distfiles

if ! [ -d "${DISTFILES}" ]; then
	mkdir ${DISTFILES}
fi

if [ -z "${VERSION}" ]; then
VERSION=2.0.24
fi

EXTRA_COMMIT=master
#EXTRA_COMMIT=8730ab75ab69edd39765fcfeed2c72226c921739

DISTFILE=inspircd-${VERSION}.tar.gz
URL=https://github.com/inspircd/inspircd/archive/v${VERSION}.tar.gz

URL_EXTRA=https://github.com/inspircd/inspircd-extras/archive/${EXTRA_COMMIT}.tar.gz
DISTFILE_EXTRA=inspircd-extras-${EXTRA_COMMIT}.tar.gz

check_errors() {
	if [ $? -ne 0 ]; then
		echo error
		exit 125
	fi
}

# do-fetch

fetch -o ${DISTFILES}/${DISTFILE} ${URL}
fetch -o ${DISTFILES}/${DISTFILE_EXTRA} ${URL_EXTRA}

check_errors
