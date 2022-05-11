#!/bin/bash

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
fzf_options=('--prompt' 'youtube search: '
             '--reverse'
             '--bind' 'change:execute-silent(ytsearch new_query {q} &)'
             '--bind' 'change:+reload(cat /tmp/ytsearch-titles)')
: | fzf ${fzf_options[@]}

kill $sleep_pid
rm /tmp/ytsearch.fifo
