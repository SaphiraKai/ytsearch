## ytsearch - an interactive terminal-based search interface for YouTube

**ytsearch** uses fzf as a frontend to display and filter search results dynamically. Every 4 characters entered will request a new query, and those results will be added to the list of search results.

### ytsearch doesn't require a YouTube API key!
The backend that handles querying YouTube and returning results is **ytscrape**. It uses **curl** to make an HTTP request, the returned webpage is filtered to remove HTML, JS, and CSS that isn't useful, and the remaining JSON data is parsed using **jq** to create a vastly simpler JSON list. Due to this, using **ytsearch** is as simple as installing and running it!

If you so desire, you can also use **ytscrape** to create your *own* search frontend for (mostly) whatever purpose you want.

### Note: Making web requests in this way isn't officially supported by YouTube.
It is entirely possible that making excessive requests will result in you being rate-limited and having your requests delayed or refused. It's very unlikely that you will be outright banned unless you *REALLY* spam those requests, but **ytsearch** only makes a request every 4 characters for a reason. Be careful with what you make using **ytscrape**!

I have no control over what YouTube/Google decides to do and I can't offer any guarantees. However, I've yet to come across any issues myself during development.

## Installation
#### Arch Linux / derivatives
```
git clone https://github.com/SaphiraKai/ytsearch
cd ytsearch
makepkg -csi
```
#### Other distributions
Ensure you have the necessary dependencies installed:
```
bash
curl
fzf
jq
xdg-open (only needed for the --open flag)
```

Then you can run the following commands:
```
git clone https://github.com/SaphiraKai/ytsearch
cd ytsearch
sudo ./install.sh
```

## Usage
Installing **ytsearch** will create three files:
```
/usr/bin/yts
/usr/bin/ytsearch
/usr/bin/ytscrape
```

#### yts
`yts` is a short alias for **ytsearch**. It sets the `--open` flag by default.

#### ytsearch
`ytsearch` is the user-friendly frontend that allows you to interactively search YouTube for a video.

If all you want to do is play a video directly, `ytsearch -o` (or simply `yts`) will do that for you!
```
-t, --title             return title of selected video
-u, --url               return url of selected video
-b, --title-url         return "title" "url" of selected video
-o, --open              don't return anything, just open selected video with xdg-open
```

#### ytscrape
`ytscrape` is a utility for 'scraping' YouTube and returning search results neatly in JSON format.

```
$ ytscrape "text to" "search for"
```

For each result, **ytscrape** will create a JSON object in the form:
```json
{
  "url",
  "title",
  "views"
}
```

The output consists of a simple list of each object.
```json
[
  {
    "url": "https://youtube.com/watch?v=ayoutubevideourl",
    "title": "A YouTube video title",
    "views": 45788
  },
  {
    "url": "https://youtube.com/watch?v=anotheryoutubevideourl",
    "title": "Another YouTube video title",
    "views": 6849
  }
]
```
The results are not sorted, so the first object in the list is the same as the first result searching YouTube normally.

As stated previously, be careful about how you use **ytscrape**. Issuing too many requests, issuing requests for illegal content, or doing anything else that Google doesn't like will have consequences that I will not be liable for!

## Tips and tricks
#### Download selected video using yt-dlp
```bash
yt-dlp "`yts -u`"
```

#### Sort by views
```bash
search_text='some text to search for'
ytscrape $search_text | jq "[.[] | select(.title|test(\"virtual riot\"; \"i\"))] | sort_by(.views) | reverse"
