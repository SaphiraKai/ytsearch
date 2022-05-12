#!/bin/bash

usage="\
usage: ytsearch [OPTION]

An interactive terminal-based search interface for YouTube

options:
	-t, --title		return title of selected video
	-u, --url		return url of selected video
	-b, --title-url	return \"title\" \"url\" of selected video
	-o, --open		don't return anything, just open selected video
					with xdg-open

	-h, --help		this help

If no OPTION, assume --url\
"

set -euo pipefail
IFS=$'\n'

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
	cat /tmp/ytsearch-search_data.json | jq -r '.[] | "\(.views)	\(.title)"' \
	> /tmp/ytsearch-titles
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

case "${1:---url}" in
	-b|--title-url) output=title_url;;
	-h|--help)      echo "$usage"; exit;;
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
             '--no-sort'
             '--prompt' 'youtube search: '
             '--bind' 'change:execute-silent(ytsearch new_query {q} &)'
             '--bind' 'change:+reload(cat /tmp/ytsearch-titles | sort -rg)'
             '--bind' 'enter:execute(echo {} > /tmp/ytsearch-selected)'
             '--bind' 'enter:+abort')

#? open the fzf-based interface
get_unique_results | fzf ${fzf_options[@]} &
fzf_pid=$!

while ps -p $fzf_pid >/dev/null; do sleep 0.1; done

[ -s /tmp/ytsearch-selected ] || { rm /tmp/ytsearch-*; exit; }
selected="$(cat /tmp/ytsearch-selected | sed 's/[0-9]*\t//')"
get_output $output "$selected"

rm -f /tmp/ytsearch-*
exit 0
