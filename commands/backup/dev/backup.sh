#!/bin/bash

_new_arguments=()

while [[ $# -gt 0 ]]; do
    case "$1" in
        --copy|-c) copy=1; shift ;;
        *) _new_arguments+=("$1"); shift ;;
    esac
done

set -- "${_new_arguments[@]}"

unset _new_arguments

# Get files from standard input.
if [ ! -t 0 ]; then
    while read _each; do
        files_arguments+=("$_each")
    done </dev/stdin
fi

# Get files from argument.
while [[ $# -gt 0 ]]; do
    files_arguments+=("$1")
    shift
done

set -- "${files_arguments[@]}"

if [ "$1" == '' ];then
    cat <<- EOF >&2
Usage: backup <file|STDIN>
       backup <file|STDIN> [<file>]...

Backup every file with suffix integer.

Options.
   -c, --copy
        Copy file instead of moving it.

Version 0.2
EOF
    exit 1
fi

while [[ $# -gt 0 ]]; do
    # Bring back filename to stdout.
    echo "$1"
    full_path=$(realpath "$1")
    dirname=$(dirname "$full_path")
    basename=$(basename -- "$full_path")
    if [ ! -f "$full_path" ];then
        echo -e "   ""\e[91m"[error]"\e[39m" File not found: "$full_path" >&2
        shift
        continue
    fi
    extension="${basename##*.}"
    if [[ "$extension" == "$basename" ]];then
        extension=
    fi
    filename="${basename%.*}"
    if [[ "$filename" =~ ~[0-9]+$ ]];then
        # echo \$filename "$filename"
        echo -e "   ""\e[33m"[warning]"\e[39m" File skipped: "$full_path" >&2
        shift
        continue
    fi
    i=1
    newfullpath="${dirname}/${filename}~${i}"
    [ -z "$extension" ] || newfullpath="$newfullpath"."$extension"
    if [[ -e "$newfullpath" || -L "$newfullpath" ]] ; then
        let i++
        newfullpath="${dirname}/${filename}~${i}"
        [ -z "$extension" ] || newfullpath="$newfullpath"."$extension"
        while [[ -e "$newfullpath" || -L "$newfullpath" ]] ; do
            let i++
            newfullpath="${dirname}/${filename}~${i}"
            [ -z "$extension" ] || newfullpath="$newfullpath"."$extension"
        done
    fi
    newbasename=$(basename -- "$newfullpath")
    if [[ $copy == 1 ]];then
        cp "$full_path" "$newfullpath"
        echo -e "   ""\e[32m"[success]"\e[39m" File copied: "$newbasename" >&2
    else
        mv "$full_path" "$newfullpath"
        echo -e "   ""\e[32m"[success]"\e[39m" File moved: "$newbasename" >&2
    fi
    # Reset.
    full_path=
    dirname=
    basename=
    extension=
    filename=
    newfullpath=
    newbasename=
    shift
done
