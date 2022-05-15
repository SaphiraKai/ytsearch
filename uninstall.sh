#!/bin/bash

set -euo pipefail
IFS=$'\t\n'

PREFIX=${PREFIX:-/usr}
DESTDIR=${DESTDIR:-}

rm -v $DESTDIR$PREFIX/bin/ytscrape
rm -v $DESTDIR$PREFIX/bin/ytsearch
rm -v $DESTDIR$PREFIX/bin/yts

echo "successfully uninstalled"
