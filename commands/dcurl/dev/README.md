# Dialog Curl

Provide dialog to input URL before executing curl.

## Setup

Download and save file as `dcurl` name.

Curl:
```
curl -L https://raw.githubusercontent.com/ijortengab/bash/master/commands/dcurl/dev/dcurl.sh -o dcurl
```

Wget:
```
wget https://raw.githubusercontent.com/ijortengab/bash/master/commands/dcurl/dev/dcurl.sh -O dcurl
```

Put file in your $PATH.

```
chmod +x dcurl
sudo mv dcurl -t /usr/local/bin
# or
[ -d ~/bin ] && mv dcurl -t ~/bin
```

## Getting Started

Example 1. Download file.

Displays a dialog box that prompts the user for input URL.

```
dcurl 1
```

Output:
```
$ dcurl 1
Variation 1.
curl -L -O -J "$url_download"
Input URL for Download (required).
$url_download: https://ftp.drupal.org/files/projects/drupal-9.1.5.tar.gz
  % Total    % Received % Xferd  Average Speed   Time    Time     Time  Current
                                 Dload  Upload   Total   Spent    Left  Speed
100 17.6M  100 17.6M    0     0  1729k      0  0:00:10  0:00:10 --:--:-- 1028k
```

Verify:
```
$ ls | grep drupal
drupal-9.1.5.tar.gz
```

Example 2. Download website page and save the file with the <title> of HTML page then add `html` extension.

Create file `~/add-html-ext.sh` with contents:

```
output="${output}.html"
preventOverrideExistingFile
```

Then execute:

```
dcurl 3 -i ~/add-html-ext.sh
```

Output:

```
$ dcurl 3 -i ~/add-html-ext.sh
Variation 3.
curl -L -H "Referer: $url_front_page" -o "$output" "$url_download"
Input URL of Front Page (required).
$url_front_page: https://stackoverflow.com/questions/40175419/curl-download-files-issue
Input URL for Download (required).
$url_download: https://stackoverflow.com/questions/40175419/curl-download-files-issue
Set filename (optional). If omitted, it will use the title of front page.
$output:
  % Total    % Received % Xferd  Average Speed   Time    Time     Time  Current
                                 Dload  Upload   Total   Spent    Left  Speed
100  162k    0  162k    0     0   146k      0 --:--:--  0:00:01 --:--:--  146k
json - cURL download files issue - Stack Overflow.html
```

## Variation

 1. `curl -L -O -J "$url_download"`
 2. `curl -L -o "$output" "$url_download"`
 3. `curl -L -H "Referer: $url_front_page"  -o "$output" "$url_download"`

## Options

Use option `-i` or `--include` to include a shell script before execute curl.
Use it to override the variable $output.
