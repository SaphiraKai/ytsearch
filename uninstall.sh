#!/bin/bash

set -euo pipefail
IFS=$'\t\n'

PREFIX=${PREFIX:-/usr}
DESTDIR=${DESTDIR:-}

rm $DESTDIR$PREFIX/bin/ytscrape
rm $DESTDIR$PREFIX/bin/ytsearch

echo "successfully uninstalled"
