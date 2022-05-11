#!/bin/bash

set -euo pipefail
IFS=$'\t\n'

new_query () {
	search=${1:-}
	(( ${#search} % 4 == 0 )) && {
		[ -s /tmp/ytsearch-search_data.json ] || echo '[]' > /tmp/ytsearch-search_data.json
		search_data="$(cat /tmp/ytsearch-search_data.json)"
		new_data="$(ytscrape $search)"
		echo "$search_data" | jq ". += $new_data | unique_by(.title)" > /tmp/ytsearch-search_data.json
	}
}

update_search () {
	cat /tmp/ytsearch-search_data.json | jq -r '.[].title' > /tmp/ytsearch-titles
}

get_unique_results () {
	declare -A memory

	set +u
	while :; do
		[ -e /tmp/ytsearch-titles ] && {
			for title in $(cat /tmp/ytsearch-titles 2>/dev/null); do
				[[ ${memory["$title"]} ]] || {
					memory["$title"]=1
					echo "$title"
				}
			done
		} || exit
	done
	set -u
}

output=title

[ "${1:-}" = new_query ] && {
	shift
	new_query "$@"
	update_search
	exit
} || [ "${1:-}" = -u ] && {
	output=url
} || [ "${1:-}" = -o ] && {
	output=open
} || [ "${1:-}" = -t ] && {
	output=title
}

touch /tmp/ytsearch-titles

#? open the fzf-based interface
fzf_options=('--prompt' 'youtube search: '
             '--reverse'
             '--bind' 'change:execute-silent(ytsearch new_query {q} &)'
             #'--bind' 'change:+reload(cat /tmp/ytsearch-titles)'
             )
get_unique_results | fzf ${fzf_options[@]} &
fzf_pid=$!

while ps -p $fzf_pid >/dev/null; do sleep 0.1; done

rm -f /tmp/ytsearch-search_data.json /tmp/ytsearch-titles
exit 0
