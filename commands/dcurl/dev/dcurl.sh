#!/bin/bash

_new_arguments=()

while [[ $# -gt 0 ]]; do
    case "$1" in
        --include=*|-i=*) include="${1#*=}"; shift ;;
        --include|-i) if [[ ! $2 == "" && ! $2 =~ ^-[^-] ]]; then include="$2"; shift; fi; shift ;;
        *) _new_arguments+=("$1"); shift ;;
    esac
done

set -- "${_new_arguments[@]}"

unset _new_arguments

if [ "$1" == '' ];then
    cat <<- 'EOF' >&2
Usage: dcurl <variation> [--include=<file>]

Dialog curl. Variations available:
   1    curl -L -O -J "$url_download"
   2    curl -L -o "$output" "$url_download"
   3    curl -L -H "Referer: $url_front_page"  -o "$output" "$url_download"

Options.
   -i, --include
        Shell script that will be included to execute before curl execution.
        Use it to override the variable $output.

Version 0.1
EOF
    exit 1
fi

if [[ ! $include == '' && ! -f "$include" ]];then
    echo "File $include not exists." >&2
    exit 1
fi

# Auto modify the variable of $output.
# If $output have value = 'a.mp3' and there are file existing named a.mp3,
# the value will modify to `a~1.mp3' and auto increment.
preventOverrideExistingFile() {
    basename=$(basename -- "$output")
    extension="${basename##*.}"
    if [[ "$extension" == "$basename" ]];then
        extension=
    fi
    filename="${basename%.*}"
    if [[ -e "$output" || -L "$output" ]] ; then
        i=1
        output="${filename}~${i}"
        [ -z "$extension" ] || output="$output"."$extension"
        while [[ -e "$output" || -L "$output" ]] ; do
            let i++
            output="${filename}~${i}"
            [ -z "$extension" ] || output="$output"."$extension"
        done
    fi
}

case "$1" in
 1) echo -e "\e[36m"Variation 1. "\e[39m"
    echo -e curl -L -O -J \""\e[33m"\$url_download"\e[39m"\"
    dialog_url_download=1
    ;;
 2) echo -e "\e[36m"Variation 2. "\e[39m"
    echo -e curl -L -o \""\e[33m"\$output"\e[39m"\" \""\e[33m"\$url_download"\e[39m"\"
    dialog_url_download=1
    dialog_output=1
    ;;
 3) echo -e "\e[36m"Variation 3. "\e[39m"
    echo -e curl -L -H \"Referer: "\e[33m"\$url_front_page"\e[39m"\" -o \""\e[33m"\$output"\e[39m"\" \""\e[33m"\$url_download"\e[39m"\"
    dialog_url_front_page=1
    dialog_url_download=1
    dialog_output=1
esac

if [[ $dialog_url_front_page == 1 ]];then
    echo -e "\e[36m""Input URL of Front Page (required).""\e[39m"
    read -p $'\e[33m'"\$url_front_page"$'\e[39m'": " url_front_page
    until [[ -n "$url_front_page" ]]; do
        read -p $'\e[33m'"\$url_front_page"$'\e[39m'": " url_front_page
    done
fi

if [[ $dialog_url_download == 1 ]];then
    echo -e "\e[36m""Input URL for Download (required).""\e[39m"
    read -p $'\e[33m'"\$url_download"$'\e[39m'": " url_download
    until [[ -n "$url_download" ]]; do
        read -p $'\e[33m'"\$url_download"$'\e[39m'": " url_download
    done
fi

if [[ $dialog_output == 1 ]];then
    if [[ $dialog_url_front_page == 1 ]];then
        echo -e "\e[36mSet filename (optional).\e[39m If omitted, it will use the title of front page."
        read -p $'\e[33m'"\$output"$'\e[39m'": " unsanitized_output
        if [ -z "$unsanitized_output" ];then
            unsanitized_output=$(curl -s -L "$url_front_page" | grep -o -E "<title>.*</title>" | sed -E "s/<title>(.*)<\/title>/\1/g")
        fi
    else
        echo -e "\e[36mSet filename (optional).\e[39m"
        read -p $'\e[33m'"\$output"$'\e[39m'": " unsanitized_output
    fi
    output=$(sed 's/[^'"'"'!@#$%^&\.,\+\{\};\[\]\(\)0123456789abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ_-]/_/g' <<< "$unsanitized_output" | sed -E 's/_+/_/g')
    [ -z "$output" ] && output=$(date +%Y%m%d%H%M%S)
    preventOverrideExistingFile
fi

if [ -f "$include" ];then
    source "$include"
fi

case "$1" in
 1) curl -L -O -J "$url_download"
    ;;
 2) curl -L -o "$output" "$url_download"
    ;;
 3) curl -L -H "Referer: $url_front_page"  -o "$output" "$url_download"
esac
if [[ $dialog_output == 1 ]];then
    echo $output
fi
