#!/bin/bash

set -euo pipefail
IFS=$'\t\n'

PREFIX=${PREFIX:-/usr}
DESTDIR=${DESTDIR:-}

rm -v $DESTDIR$PREFIX/bin/ytscrape
rm -v $DESTDIR$PREFIX/bin/ytsearch

echo "successfully uninstalled"
