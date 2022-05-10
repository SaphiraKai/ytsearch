#!/bin/bash
search=$@
encoded="$(echo $search | sed 's/ /+/g')"

IFS=$'\n'

get_listing () {
	sed -e 's/,/\n/' -e 's/;/\n/' |\
	grep -oP '"title":{"runs":\[{"text":".*?"}]'
}

trim_nonresults () {
	sed 's/Search options/END-OF-RESULTS/' |\
	sed '/END-OF-RESULTS/,$ d'
}

clean_strings () {
	sed 's/.*"text":"//' | sed 's/"}]$//'
}

url="https://www.youtube.com/results?&search_query=$encoded&max_results=20"

echo -e "$(curl $url)"
