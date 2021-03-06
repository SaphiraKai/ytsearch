#!/bin/bash
search=$@
encoded="$(echo $search | sed 's/ /+/g')"

IFS=$'\n'

extract_json () {
	grep -oP 'var ytInitialData = \K{.*}' | jq 2>/dev/null
}

filter_json () {
	jq -R 'fromjson? | .'
}

parse_json () {
	jq \
"[
  .contents
  .twoColumnSearchResultsRenderer
  .primaryContents
  .sectionListRenderer
  .contents[0]
  .itemSectionRenderer
  .contents[]
  .videoRenderer | select( . != null ) | {
    url: .navigationEndpoint.commandMetadata.webCommandMetadata.url | \"https://youtube.com\(.)\",
    title: .title.runs[0].text,
    views: .viewCountText.simpleText | rtrimstr(\" views\") | split(\",\") | join(\"\") | tonumber
  }
]
"
}

url="https://www.youtube.com/results?&search_query=$encoded&max_results=20"

echo -e "$(curl -s $url)" | extract_json | parse_json

