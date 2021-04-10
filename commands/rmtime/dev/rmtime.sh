#!/bin/bash

_new_arguments=()

while [[ $# -gt 0 ]]; do
    case "$1" in
        --duration=*|-d=*) duration="${1#*=}"; shift ;;
        --duration|-d) if [[ ! $2 == "" && ! $2 =~ ^-[^-] ]]; then duration="$2"; shift; fi; shift ;;
        *) _new_arguments+=("$1"); shift ;;
    esac
done

set -- "${_new_arguments[@]}"

unset _new_arguments

isVideo() {
    # Populer.
    if [[ "$extension" == 'mp4' ]];then return 0
    # Other.
    elif [[ $(file "$full_path"  -i | sed -n 's!: video/[^:]*$!!p') ]];then return 0
    fi
    return 1
}

getDuration() {
    local _full_path="$full_path"
    # ffmpeg yang terinstal pada host Windows tidak mengenali path Cygwin maupun
    # WSL2, maka konversi "$full_path" ke path-nya Windows.
    # Jika command ini dieksekusi di Cygwin, maka:
    if command -v cygpath.exe &> /dev/null
    then
        _full_path=$(cygpath.exe -w "$full_path")
    # Jika command ini dieksekusi di WSL2, maka:
    elif command -v wslpath &> /dev/null
    then
        _full_path=$(wslpath -w "$full_path")
    fi
    if command -v ffmpeg &> /dev/null
    then
        ffmpeg -i "$_full_path" 2>&1 | grep -o -P "(?<=Duration: ).*?(?=,)"
    # ffmpeg.exe for WSL2.
    elif command -v ffmpeg.exe &> /dev/null
    then
        ffmpeg.exe -i "$_full_path" 2>&1 | grep -o -P "(?<=Duration: ).*?(?=,)"
    fi
}

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
Usage: rmtime <file|STDIN> [--duration=<duration>]
       rmtime <file|STDIN> [<file>]...

Reset the modification time of file with datetime information in filename.

Options.
   -d, --duration
        Add duration, for video file only if ffmpeg not exists

Version 0.1
EOF
    exit 1
fi

if [[ $# -gt 1 && ! $duration == '' ]];then
    echo The --duration option can only be used with one operand. >&2
    exit 1
fi

while [[ $# -gt 0 ]]; do
    # Bring back filename to stdout.
    echo "$1"
    full_path=$(realpath "$1")
    basename=$(basename -- "$full_path")
    if [ ! -f "$full_path" ];then
        echo -e "   ""\e[91m"[ error ]"\e[39m" File not found: "$full_path" >&2
        shift
        continue
    fi
    extension="${basename##*.}"
    extension=$(echo "$extension" | tr '[:upper:]' '[:lower:]')
    filename="${basename%.*}"
    digit=$(echo "$filename" | sed -E 's|[^0-9]||g')
    s=${digit:0:14}
    if [[ ! ${#s} == 14 ]];then
        echo -e "   ""\e[91m"[ skip ]"\e[39m" Digit that represents of YYYYMMDDHHMMSS not found in filename: "$basename". >&2
        shift
        continue
    fi
    if isVideo;then
        if [[ "$duration" == '' ]];then
            duration=`getDuration`
        fi
        if [[ "$duration" == '' ]];then
            echo -e "   ""\e[91m"[ skip ]"\e[39m" Duration not found. For precisision, add --duration option with format argument: \"[[hh:]mm:]ss\" >&2
            shift
            continue
        fi
        add_s=$(echo $duration | grep -E -o "[0-9.]+$")
        add_m=$(echo $duration | grep -E -o "[0-9]+:[0-9.]+$" | sed -E "s|:[0-9.]+$||")
        add_h=$(echo $duration | grep -E -o "[0-9]+:[0-9]+:[0-9.]+$" | sed -E "s|:[0-9]+:[0-9.]+$||")
    fi
    if [[ ! $add_s == '' ]];then
        s=$(date -u -d "${s:0:8} ${s:8:2}:${s:10:2}:${s:12:2} UTC +${add_s} sec" '+%Y%m%d%H%M%S')
    fi
    if [[ ! $add_m == '' ]];then
        s=$(date -u -d "${s:0:8} ${s:8:2}:${s:10:2}:${s:12:2} UTC +${add_m} min" '+%Y%m%d%H%M%S')
    fi
    if [[ ! $add_h == '' ]];then
        s=$(date -u -d "${s:0:8} ${s:8:2}:${s:10:2}:${s:12:2} UTC +${add_h} hour" '+%Y%m%d%H%M%S')
    fi
    echo -e "   ""\e[92m"[ ok ]"\e[39m" "\e[93m"touch"\e[39m" "\e[95m"-m"\e[39m" "$1" "\e[95m"-t"\e[39m" "${s:0:12}.${s:12:14}" >&2
    touch -m "$1" -t "${s:0:12}.${s:12:14}"
    # Reset.
    duration=
    add_s=
    add_m=
    add_h=
    full_path=
    basename=
    extension=
    filename=
    digit=
    shift
done
