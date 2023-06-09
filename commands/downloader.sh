#!/bin/bash

command -v "inotifywait" >/dev/null || { echo "inotifywait command not found."; exit 1; }
command -v "youtube-dl" >/dev/null || { echo "youtube-dl command not found."; exit 1; }
command -v "curl" >/dev/null || { echo "curl command not found."; exit 1; }
command -v "screen" >/dev/null || { echo "screen command not found."; exit 1; }

_new_arguments=()

while [[ $# -gt 0 ]]; do
    case "$1" in
        --directory=*|-d=*) directory="${1#*=}"; shift ;;
        --directory|-d) if [[ ! $2 == "" && ! $2 =~ ^-[^-] ]]; then directory="$2"; shift; fi; shift ;;
        --feed=*|-f=*) feed="${1#*=}"; shift ;;
        --feed|-f) if [[ ! $2 == "" && ! $2 =~ ^-[^-] ]]; then feed="$2"; shift; fi; shift ;;
        --history=*|-h=*) history="${1#*=}"; shift ;;
        --history|-h) if [[ ! $2 == "" && ! $2 =~ ^-[^-] ]]; then history="$2"; shift; fi; shift ;;
        *) _new_arguments+=("$1"); shift ;;
    esac
done

set -- "${_new_arguments[@]}"

_new_arguments=()

while [[ $# -gt 0 ]]; do
    case "$1" in
        -[^-]*) OPTIND=1
            while getopts ":d:f:h:" opt; do
                case $opt in
                    d) directory="$OPTARG" ;;
                    f) feed="$OPTARG" ;;
                    h) history="$OPTARG" ;;
                esac
            done
            shift "$((OPTIND-1))"
            ;;
        *) _new_arguments+=("$1"); shift ;;
    esac
done

set -- "${_new_arguments[@]}"

unset _new_arguments

[ -z "$directory" ] && directory=$PWD
[ -z "$feed" ] && feed='downloader-feed.txt'
[ -z "$history" ] && history='downloader-history.txt'
feed="${directory}/${feed}"
history="${directory}/${history}"

ISCYGWIN=
if [[ $(uname | cut -c1-6) == "CYGWIN" ]];then
    ISCYGWIN=1
fi
if [[ -z "$1" ]];then
    echo Working directory is \'"$directory"\'.
    echo Feed file is \'"$feed"\'.
    echo History file is \'"$history"\'.
    [ -f "$feed" ] || { echo "feed file is not found."; exit 1; }
    [ -n "$ISCYGWIN" ] && feed=$(cygpath -w "$feed")
    inotifywait -m "$feed" -e modify | while read -r a b c; do "$0" execute; done
fi
if [[ "$1" == 'read' ]];then
    [ -f "$feed" ] || { echo "feed file is not found."; exit 1; }
    cat "$feed"
fi
if [[ "$1" == 'execute' ]];then
    # Script dimulai.
    content=$(<"$feed")
    url_front_page=$(sed '1q;d' <<< "$content")
    url_download=$(sed '2q;d' <<< "$content")
    output=$(sed '3q;d' <<< "$content")
    additional_command=$(sed '4q;d' <<< "$content")
    findword="<$url_front_page>"
    if grep -q -o -F "$findword" "$history";then
        echo URL \'"$url_front_page"\' has beeen downloaded.
        exit 1
    fi
    [ -z "$url_download" ] && {
        echo URL download is empty.
        exit 1
    }
    echo "$findword" >> "$history"
    if [ -z "$output" ];then
        output="$(date +%Y%m%d_%H%M%S)"
    fi
    if [ -n "$additional_command" ];then
        eval "$additional_command"
    fi
    # Example of additional_command
    # output=$(date +%Y%m%d_%H%M%S)"_${output}.mp4"
    echo \$url_front_page: "$url_front_page"
    echo \$url_download: "$url_download"
    echo \$output: "$output"
    if [[ "$url_download" =~ m3u8 ]];then
        screen -d -m youtube-dl --no-check-certificate --add-header "Referer: $url_front_page" --no-playlist \
            --format mp4 --write-all-thumbnails  --output "$output" "$url_download"
    else
        screen -d -m curl -L -H "Referer: $url_front_page" -o "$output" "$url_download"
    fi
fi
