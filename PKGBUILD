# Maintainer: Saphira Kai
pkgname=ytsearch
pkgver=r15.a54559c
pkgrel=1
epoch=
pkgdesc="An interactive terminal-based search interface for YouTube"
arch=(any)
url="https://github.com/SaphiraKai/ytsearch"
license=('GPLv2')
groups=()
depends=('bash' 'jq' 'fzf' 'curl')
makedepends=()
checkdepends=()
optdepends=('xdg-open: for opening videos automatically')
provides=('ytsearch' 'ytscrape')
conflicts=()
replaces=()
backup=()
options=()
install=
changelog=
source=('ytscrape.sh'
        'ytsearch.sh'
        'install.sh')
noextract=()
sha256sums=('SKIP' 'SKIP' 'SKIP')
validpgpkeys=('2916041854F0C0C2786846345B407F5B67CAAA85')

pkgver() {
	(
		set -o pipefail
		git describe --long 2>/dev/null | sed 's/\([^-]*-g\)/r\1/;s/-/./g' ||
		printf "r%s.%s" "$(git rev-list --count HEAD)" "$(git rev-parse --short HEAD)"
	)
}

#prepare() {}

#build() {}

#check() {}

package() {
	cd "$srcdir"
	DESTDIR="$pkgdir/" ./install.sh
}
