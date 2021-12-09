#!/bin/bash

# Provide fast way to save backup of file.
#
# Example 1.
#
#   ```
#   touch myfile
#   backup.sh myfile
#   ```
#
#   Command above will move `myfile` to `myfile (1)`.
#
# Example 2.
#
#   ```
#   echo 'bla bla' > mynote.txt
#   backup.sh mynote.txt -c
#   echo 'wow wow' >> mynote.txt
#   backup.sh mynote.txt -c
#   ```
#
#   Command above will copy the origin `mynote.txt` to `mynote (1).txt` then
#   copy the modified of `mynote.txt` to `mynote (2).txt`.
#   The contents of `mynote (1).txt` is:
#
#   ```
#   bla bla
#   ```
#
#   The contents of `mynote (2).txt` is:
#
#   ```
#   bla bla
#   wow wow
#   ```
#
# Example 3.
#
#   ```
#   touch myimage.jpg \
#         myimage (1).jpg \
#         myimage (2).jpg
#   backup.sh myimage.jpg
#   ```
#
#   Command above will move `myimage.jpg` to `myimage (3).jpg`.
#
# Options
#   -c, --copy        Copy the original source instead of moving it.
#   -t, --target-directory
#                     Set target directory to save backup.
#
# Bulk Process
#   Works well with asterix.
#
#   ```
#   backup.sh *.mp4
#   ```
#
#   or standard input.
#
#   ```
#   ls *.jpg | backup.sh
#   ```
#

_new_arguments=()

while [[ $# -gt 0 ]]; do
    case "$1" in
        --copy|-c) copy=1; shift ;;
        --target-directory=*|-t=*) target_directory="${1#*=}"; shift ;;
        --target-directory|-t) if [[ ! $2 == "" && ! $2 =~ ^-[^-] ]]; then target_directory="$2"; shift; fi; shift ;;
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
   -t <d>, --target-directory <d>
        Backup file to target directory.

Version 0.3
EOF
    exit 1
fi
if [ -n "$target_directory" ];then
    # Trim trailing slash.
    target_directory=${target_directory%/}
    target_directory_full_path=$(realpath "$target_directory")
    if [ ! -d "$target_directory_full_path" ];then
        echo -e "   ""\e[91m"[error]"\e[39m" Directory not found: "$target_directory_full_path" >&2
        exit 1
    fi
fi

while [[ $# -gt 0 ]]; do
    # Bring back filename to stdout.
    echo "$1"
    full_path=$(realpath --no-symlinks "$1")
    dirname=$(dirname "$full_path")
    basename=$(basename -- "$full_path")
    notfound=1
    if [ -f "$full_path" ];then
        notfound=0
        which=File
    elif [ -L "$full_path" ];then
        notfound=0
        which=Link
    elif [ -d "$full_path" ];then
        notfound=0
        which=Directory
    fi
    if [[ "$notfound" == 1 ]];then
        echo -e "   ""\e[91m"[error]"\e[39m" File or directory not found: "$full_path" >&2
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
    newdirname="$dirname"
    if [ -n "$target_directory_full_path" ];then
        newdirname="$target_directory_full_path"
    fi
    newfullpath="${newdirname}/${filename} (${i})"
    [ -z "$extension" ] || newfullpath="$newfullpath"."$extension"
    if [[ -e "$newfullpath" || -L "$newfullpath" ]] ; then
        let i++
        newfullpath="${newdirname}/${filename} (${i})"
        [ -z "$extension" ] || newfullpath="$newfullpath"."$extension"
        while [[ -e "$newfullpath" || -L "$newfullpath" ]] ; do
            let i++
            newfullpath="${newdirname}/${filename} (${i})"
            [ -z "$extension" ] || newfullpath="$newfullpath"."$extension"
        done
    fi
    newbasename=$(basename -- "$newfullpath")
    [ -n "$target_directory" ] && newbasename="$target_directory"/"$newbasename"
    if [[ $copy == 1 ]];then
        if [[ $which == Directory ]];then
            cp -r "$full_path" "$newfullpath"
        else
            cp "$full_path" "$newfullpath"
        fi
        if [[ -e "$newfullpath" || -L "$newfullpath" ]] ; then
            echo -e "   ""\e[32m"[success]"\e[39m" $which copied: "$newbasename" >&2
        else
            echo -e "   ""\e[91m"[error]"\e[39m" Copy failed. File or directory not found: "$newfullpath" >&2
        fi
    else
        mv "$full_path" "$newfullpath"
        if [[ -e "$newfullpath" || -L "$newfullpath" ]] ; then
            echo -e "   ""\e[32m"[success]"\e[39m" $which moved: "$newbasename" >&2
        else
            echo -e "   ""\e[91m"[error]"\e[39m" Move failed. File or directory not found: "$newfullpath" >&2
        fi
    fi
    # Reset.
    which=
    full_path=
    dirname=
    basename=
    extension=
    filename=
    newfullpath=
    newbasename=
    newdirname=
    shift
done
