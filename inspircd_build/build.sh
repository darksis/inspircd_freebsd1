#!/bin/sh

CURDIR=${PWD}

if [ -z "${VERSION}" ]; then
VERSION=2.0.24
fi

if [ -z "${WRKSRC}" ]; then
WRKSRC=${CURDIR}/inspircd-${VERSION}
fi

PREFIX=${CURDIR}/inspircd
BINARY_DIR=${PREFIX}/bin
MODULE_DIR=${PREFIX}/modules
CONFIG_DIR=${PREFIX}/config
DATA_DIR=${PREFIX}/data
LOG_DIR=${PREFIX}/log

LOCALBASE=/usr/local

if [ -z "${MAKE_JOBS_NUMBER}" ]; then
SMP_CPUS=`sysctl -n kern.smp.cpus`
if [ ${SMP_CPUS} -ge 2 ]; then
MAKE_JOBS_NUMBER=$(expr ${SMP_CPUS} - 1)
else
MAKE_JOBS_NUMBER=1
fi
fi
MAKE_JOBS=-j${MAKE_JOBS_NUMBER}

check_errors() {
	if [ $? -ne 0 ]; then
		echo error
		exit 125
	fi
}

MODULES="m_regex_pcre.cpp m_regex_posix.cpp m_regex_stdlib.cpp m_geoip.cpp m_sqlite3.cpp m_ssl_gnutls.cpp m_ssl_openssl.cpp"
# m_ldapauth.cpp m_ldapoper.cpp m_mysql.cpp m_pgsql.cpp m_regex_tre.cpp
#? m_mssql.cpp

#MODULES_EXTRA="`cd inspircd-extras-*/2.0 && ls *.cpp | sort -n`"
MODULES_EXTRA="m_accounthost.cpp m_antibear.cpp m_antibottler.cpp m_anticaps.cpp m_antirandom.cpp m_ascii.cpp m_authy.cpp m_autodrop.cpp m_autokick.cpp m_bannegate.cpp m_blockhighlight.cpp m_blockinvite.cpp m_cap_chghost.cpp m_capnotify.cpp m_cgiircban.cpp m_changecap.cpp m_ciphersuitejoin.cpp m_classban.cpp m_conn_banner.cpp m_conn_delayed_join.cpp m_conn_matchident.cpp m_conn_vhost.cpp m_custompenalty.cpp m_dccblock.cpp m_deferaccept.cpp m_disablemodes.cpp m_extbanredirect.cpp m_extbanregex.cpp m_findxline.cpp m_flashpolicyd.cpp m_forceident.cpp m_fullversion.cpp m_geoipban.cpp m_hash_gnutls.cpp m_hideidle.cpp m_identmeta.cpp m_invitenotify.cpp m_ircv3_sts.cpp m_ircxusernames.cpp m_join0.cpp m_joinoninvite.cpp m_joinpartsno.cpp m_joinpartspam.cpp m_lusersnoservices.cpp m_messagelength.cpp m_namedstats.cpp m_nickdelay.cpp m_nickin001.cpp m_nocreate.cpp m_noctcp_user.cpp m_nooponcreate.cpp m_nouidnick.cpp m_opmoderated.cpp m_override_umode.cpp m_pretenduser.cpp m_privdeaf.cpp m_qrcode.cpp m_quietban.cpp m_rehashsslsignal.cpp m_replaymsg.cpp m_require_auth.cpp m_requirectcp.cpp m_rotatelog.cpp m_rpg.cpp m_sha1.cpp m_slowmode.cpp m_solvemsg.cpp m_sslstats_gnutls.cpp m_stats_unlinked.cpp m_svsoper.cpp m_timedstaticquit.cpp m_topicall.cpp m_totp.cpp m_xmlsocket.cpp"
# m_regex_re2.cpp

CONFIGURE_EXTRA_ARGS=--disable-interactive
for m in ${MODULES} ${MODULES_EXTRA}; do
	CONFIGURE_EXTRA_ARGS="${CONFIGURE_EXTRA_ARGS} --enable-extras=${m}"
done

cd ${WRKSRC}

# do-patch
#patch -f -s < /usr/ports/irc/inspircd/files/patch-make_template_main.mk
NEWLINE=$'\n'
sed -i '.bak' -e "/^CXXFLAGS =/s|$|\\${NEWLINE}CXXFLAGS += -I${LOCALBASE}/include| ; /^LDFLAGS =/s|$|\\${NEWLINE}LDFLAGS += -L${LOCALBASE}/lib| ; /^@DO_EXPORT RUNCC/s|$| LDFLAGS|" \
	make/template/main.mk

# do-configure
./configure ${CONFIGURE_EXTRA_ARGS}

check_errors

./configure \
	--uid=0 \
	--prefix="${PREFIX}" \
	--binary-dir="${BINARY_DIR}" \
	--module-dir="${MODULE_DIR}" \
	--config-dir="${CONFIG_DIR}" \
	--data-dir="${DATA_DIR}" \
	--log-dir="${LOG_DIR}" \
	--enable-kqueue \
	--enable-openssl \
	--enable-gnutls \
	--disable-interactive

check_errors

# do-build
make -f BSDmakefile ${MAKE_JOBS}

check_errors

# do-install
make -f BSDmakefile install
