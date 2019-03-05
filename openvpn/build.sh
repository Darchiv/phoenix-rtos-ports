#!/bin/bash
OPENVPN=openvpn-2.4.7

b_log "Building openvpn"
PREFIX_OPENVPN=${TOPDIR}/phoenix-rtos-ports/openvpn
PREFIX_OPENVPN_BUILD=${PREFIX_BUILD}/openvpn
PREFIX_OPENVPN_SRC=${PREFIX_OPENVPN}/${OPENVPN}

#
# Download and unpack
#
mkdir -p "$PREFIX_OPENVPN_BUILD"

if [ ! -z "$CLEAN" ]; then

	rm -fr $PREFIX_OPENVPN_BUILD/*

	[ -f "$PREFIX_OPENVPN/${OPENVPN}.tar.gz" ] || wget https://swupdate.openvpn.org/community/releases/${OPENVPN}.tar.gz -P "$PREFIX_OPENVPN"
	if [ ! -d "$PREFIX_OPENVPN_SRC" ]; then
	   	tar zxf "$PREFIX_OPENVPN/${OPENVPN}.tar.gz" -C "$PREFIX_OPENVPN"

#
#  Apply patch
#
		cd $PREFIX_OPENVPN_SRC
		for i in ${PREFIX_OPENVPN}/*.patch; do patch -t -p1 < $i; done

	fi
	OPENVPN_CFLAGS="-I$TOPDIR/_build/arm-imx6ull/openssl/include/ ${CFLAGS} -std=gnu99"
	OPENVPN_LDFLAGS="-L$TOPDIR/_build/arm-imx6ull/openssl/lib/ ${LDFLAGS}"
	
#
# Configure
#
	cd $PREFIX_OPENVPN_SRC
	autoreconf -i -v -f	
	PKG_CONFIG="" ./configure CFLAGS="${OPENVPN_CFLAGS}" LDFLAGS="${OPENVPN_LDFLAGS}" --host=arm-phoenix
fi

#
# Make
#
make -C "$PREFIX_OPENVPN_SRC" -j 9
cd $TOPDIR
