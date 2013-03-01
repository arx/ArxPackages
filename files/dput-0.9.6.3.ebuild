# Copyright 1999-2013 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=4

inherit bash-completion-r1

MY_PV="${PV}+nmu1ubuntu1"
MY_P="${PN}_${MY_PV}"
S="${WORKDIR}/${PN}-${MY_PV}"

DESCRIPTION="Debian package upload tool"
HOMEPAGE="https://launchpad.net/ubuntu/+source/dput/"
SRC_URI="mirror://ubuntu/pool/main/d/${PN}/${MY_P}.tar.gz"

LICENSE="GPL-2+"
SLOT="0"
KEYWORDS="~x86 ~amd64"
IUSE="bash-completion"

RDEPEND="dev-lang/python
	app-crypt/gnupg"
DEPEND="${RDEPEND}"

src_install() {

	dobin dput
	doman dput.1

	dobin dcut
	doman dcut.1

	insinto /etc
	doins dput.cf
	doman dput.cf.5

	insinto /usr/share/dput
	doins ftp.py
	doins http.py
	doins https.py
	doins scp.py
	doins sftp.py
	doins local.py
	doins rsync.py

	insinto /usr/share/dput/helper
	doins dputhelper.py

	exeinto /usr/share/dput/helper
	doexe security-warning

	dodoc README FAQ copyright TODO THANKS debian/changelog

	use bash-completion && newbashcomp bash_completion ${PN}

}
