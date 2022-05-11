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
             '--bind' 'change:+reload(cat /tmp/ytsearch-titles)')
: | fzf ${fzf_options[@]}

rm /tmp/ytsearch-search_data.json /tmp/ytsearch-titles
