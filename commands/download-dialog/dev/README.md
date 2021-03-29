# Download Dialog

Provide dialog to input URL before executing command to download.

## Setup

Download and save file as `download-dialog` name.

Curl:
```
curl -L https://git.io/download-dialog.sh -o download-dialog
```

Wget:
```
wget https://git.io/download-dialog.sh -O download-dialog
```

Put file in your $PATH.

```
chmod +x download-dialog
sudo mv download-dialog -t /usr/local/bin
# or
[ -d ~/bin ] && mv download-dialog -t ~/bin
```

## Getting Started

Example 1. Download file with curl.

Displays a dialog box that prompts the user for input URL.

```
download-dialog curl
```

Output:
```
Download Dialog.
 curl -L -O -J "$url_download"
Input URL for Download.
 $url_download:
```
Type the URL, then press Enter. The next output:
```
Download Dialog.
 curl -L -O -J "$url_download"
Preview.
 $url_download: https://ftp.drupal.org/files/projects/drupal-9.1.5.tar.gz
Option:
 [a] Edit all
 [e] Edit empty only
 [ ] Finish
Select:
```
Enter. The next output:
```
Download Dialog.
 curl -L -O -J "https://ftp.drupal.org/files/projects/drupal-9.1.5.tar.gz"
Option:
 [Ctrl+c] Cancel
 [Enter ] Execute
Select:
```
Enter and curl downloading the file.

## Other variation

There are 7 variation to download the URL.

```
Usage: download-dialog <command> [--include=<file>]

Commands available.
   curl
      curl -L -O -J "$url_download"
   curl saveas
      curl -L -o "$output" "$url_download"
   curl saveas referer
      curl -L -H "Referer: $url_front_page" -o "$output" "$url_download"
   wget
      wget "$url_download"
   wget saveas
      wget -O "$output" "$url_download"
   youtube-dl
      youtube-dl "$url_download" --no-playlist --format mp4 --write-all-thumbnails
   youtube-dl referer
      youtube-dl --add-header "Referer: $url_front_page" --no-playlist --format mp4 --write-all-thumbnails "$url_download"

Options.
   -i, --include
        Shell script that will be included to execute before download execution.
        Use it to override any variable.

Note.
   The variable "$output" is not mandatory, and will be autopopulate with the
   date if empty or use the title of "$url_front_page" if any.

Version 0.1
```

## Autocompletion

Copy paste `bash_completion.d/download-dialog` file to `/etc/bash_completion.d`
directory for quick typing subcommand with TAB key.

```
wget https://git.io/download-dialog-completion.sh
mv download-dialog-completion.sh /etc/bash_completion.d/download-dialog
```

Implements now,

```
source /etc/bash_completion.d/download-dialog
```

or relaunch terminal.

## Options

Example 2. Using `--include` option:

We have scenario below:

> Download website page and save the file with the <title> of HTML page then add `html` extension.

Create file `~/add-html-ext.sh` with contents:

```
output="${output}.html"
PreventOverrideExistingFile
```

Then execute:

```
download-dialog curl saveas referer -i ~/add-html-ext.sh
```

Output, Page 1:

```
Download Dialog.
 curl -L -H "Referer: $url_front_page" -o "$output" "$url_download"
Input URL for Download.
 $url_download: https://stackoverflow.com/questions/40175419/curl-download-files-issue
Input URL Front Page.
 $url_front_page: https://stackoverflow.com/questions/40175419/curl-download-files-issue
Output filename.
 $output:
```

Output, Page 2:

```
Download Dialog.
 curl -L -H "Referer: $url_front_page" -o "$output" "$url_download"
Preview.
 $url_download: https://stackoverflow.com/questions/40175419/curl-download-files-issue
 $url_front_page: https://stackoverflow.com/questions/40175419/curl-download-files-issue
 $output:
Option:
 [a] Edit all
 [e] Edit empty only
 [ ] Finish
Select:
 [ ] Finish
```

Output, Page 3:

```
Download Dialog.
 curl -L -H "Referer: $url_front_page" -o "$output" "$url_download"
Preview.
 $url_download: https://stackoverflow.com/questions/40175419/curl-download-files-issue
 $url_front_page: https://stackoverflow.com/questions/40175419/curl-download-files-issue
 $output:
Option:
 [a] Edit all
 [e] Edit empty only
 [ ] Finish
Select:
 [ ] Finish
```

```
Download Dialog.
 curl -L -H "Referer: https://stackoverflow.com/questions/40175419/curl-download-files-issue" -o "json - cURL download files issue - Stack Overflow.html" "https://stackoverflow.com/questions/40175419/curl-download-files-issue"
Option:
 [Ctrl+c] Cancel
 [Enter ] Execute
Select:
```

With command above, the output has suffixed with string `.html`.

Enter and curl downloading the file.

## youtube-dl

Before using `youtube-dl`, make sure the `ffmpeg` command has recognize in environment variable $PATH.

```
which youtube-dl
which ffmpeg
```

If there are doesn't exists:

For Windows User which using WSL 2, install `Format Factory` which included `ffmpeg.exe`.

Then add this line in `.bashrc`:

```
# For Cygwin.
export PATH=$PATH:'/cygdrive/c/Program Files (x86)/FormatFactory'
# For WSL2.
export PATH=$PATH:'/mnt/c/Program Files (x86)/FormatFactory'
```

Binary `youtube-dl.exe` for Windows can download directly from their website.
