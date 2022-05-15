#!/bin/bash
# pseudo-alias for ytsearch

#? if no arguments given, use --open for convenience of interactive use
[ $# = 0 ] && {
	args='--open'
} || {
	args=$@
}

ytsearch $args
