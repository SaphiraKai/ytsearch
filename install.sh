#!/bin/bash

set -euo pipefail
IFS=$'\t\n'

PREFIX=${PREFIX:-/usr}
DESTDIR=${DESTDIR:-}

install -Dvm 755 ytscrape.sh $DESTDIR$PREFIX/bin/ytscrape
install -Dvm 755 ytsearch.sh $DESTDIR$PREFIX/bin/ytsearch

echo "successfully installed"
