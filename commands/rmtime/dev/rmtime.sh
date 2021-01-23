#!/bin/bash
isVideo() {
    # Populer.
    if [[ "$extension" == 'mp4' ]];then return 0
    # Other.
    elif [[ $(file "$full_path"  -i | sed -n 's!: video/[^:]*$!!p') ]];then return 0
    fi
    return 1
}
getDuration() {
    if command -v ffmpeg &> /dev/null
    then
        ffmpeg -i "$1" 2>&1 | grep -o -P "(?<=Duration: ).*?(?=,)"
    # For WSL2.
    elif command -v ffmpeg.exe &> /dev/null
    then
        ffmpeg.exe -i "$1" 2>&1 | grep -o -P "(?<=Duration: ).*?(?=,)"
    fi
}
if [ "$1" == '' ];then
    cat <<- EOF >&2
Reset the modification time of file if there is date information in filename.

Usage: rmtime <file> [<duration>]
EOF
    exit 1
fi
if [ ! -f "$1" ];then
    echo File not found: "$1" >&2
    exit 1
fi
full_path=$(realpath "$1")
basename=$(basename -- "$full_path")
extension="${basename##*.}"
extension=$(echo "$extension" | tr '[:upper:]' '[:lower:]')
filename="${basename%.*}"
if isVideo;then
    duration=`getDuration "$1"`
    [ $duration ] || duration="$2"
    if [[ "$duration" == '' ]];then
        echo Need length of video at second argument with format \"[[hh:]mm:]ss\" >&2
        exit 1
    else
        add_s=$(echo $duration | grep -E -o "[0-9.]+$")
        add_m=$(echo $duration | grep -E -o "[0-9]+:[0-9.]+$" | sed -E "s|:[0-9.]+$||")
        add_h=$(echo $duration | grep -E -o "[0-9]+:[0-9]+:[0-9.]+$" | sed -E "s|:[0-9]+:[0-9.]+$||")
    fi
fi
digit=$(echo "$filename" | sed -E 's|[^0-9]||g')
s=${digit:0:14}
if [[ ! ${#s} == 14 ]];then
    echo Digit that represents of YYYYMMDDHHMMSS not found in filename. >&2
    exit 2
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
echo -e "\e[92m"[ ok ]"\e[39m" "\e[93m"touch"\e[39m" "\e[95m"-m"\e[39m" "$1" "\e[95m"-t"\e[39m" "${s:0:12}.${s:12:14}" >&2
touch -m "$1" -t "${s:0:12}.${s:12:14}"
# Bring back filename to stdout.
echo "$1"
