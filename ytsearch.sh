#!/bin/bash

fzf_options=('--bind' 'change:execute-silent(ytsearch scrape {q})')

set -euo pipefail
IFS=$'\t\n'

scrape () {
	search=${1:-}
	(( ${#search} % 4 == 0 )) && {
		ytscrape "$search" >> /tmp/ytsearch.fifo &
	}
}

[ "${1:-}" = scrape ] && {
	shift
	scrape "$@"
	exit
}

#? create a fifo for the search results
[ -e /tmp/ytsearch.fifo ] || mkfifo /tmp/ytsearch.fifo

#? keep pipe open
sleep infinity > /tmp/ytsearch.fifo &
sleep_pid=$!

#? open the fzf-based interface
fzf ${fzf_options[@]}  < /tmp/ytsearch.fifo

kill $sleep_pid
rm /tmp/ytsearch.fifo
