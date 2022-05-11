#!/bin/bash

set -euo pipefail
IFS=$'\t\n'

get_output () {
	output=$1
	title="$2"

	[ $output = title_url ] && {
		cat /tmp/ytsearch-search_data.json | \
		jq -r ".[] | select(.title == \"$title\") | "'"\"\(.title)\" \"\(.url)\""'
	} || [ $output = open ] && {
		xdg-open $(cat /tmp/ytsearch-search_data.json | jq -r ".[] | select(.title == \"$title\").url")
	} || {
		cat /tmp/ytsearch-search_data.json | \
		jq -r ".[] | select(.title == \"$title\").$output"
	}
}

new_query () {
	search=${1:-}
	(( ${#search} % 4 == 0 )) && {
		[ -s /tmp/ytsearch-search_data.json ] ||\
		echo '[]' > /tmp/ytsearch-search_data.json

		search_data="$(cat /tmp/ytsearch-search_data.json)"
		new_data="$(ytscrape $search)"

		echo "$search_data" | jq ". += $new_data | unique_by(.title)" \
		> /tmp/ytsearch-search_data.json
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

case "${1:--t}" in
	-b|--title-url) output=title_url;;
	-o|--open)      output=open;;
	-t|--title)     output=title;;
	-u|--url)       output=url;;

	new_query)
		shift
		new_query "$@"
		update_search
		exit
		;;

	*) 2>&1 echo "ytsearch: unrecognized argument '$1'";;
esac

touch /tmp/ytsearch-titles

fzf_options=('--reverse'
             '--prompt' 'youtube search: '
             '--bind' 'change:execute-silent(ytsearch new_query {q} &)'
             '--bind' 'enter:execute(echo {} > /tmp/ytsearch-selected)'
             '--bind' 'enter:+abort')

#? open the fzf-based interface
get_unique_results | fzf ${fzf_options[@]} &
fzf_pid=$!

while ps -p $fzf_pid >/dev/null; do sleep 0.1; done

selected="$(cat /tmp/ytsearch-selected)"
get_output $output "$selected"

rm -f /tmp/ytsearch-*
exit 0
