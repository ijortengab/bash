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

ArraySearch() {
    local index match="$1"
    local source=("${!2}")
    for index in "${!source[@]}"; do
       if [[ "${source[$index]}" == "${match}" ]]; then
           _return=$index; return 0
       fi
    done
    return 1
}

ArrayRemove() {
    local index match="$1"
    _return=("${!2}")
    for index in "${!_return[@]}"; do
       if [[ "${_return[$index]}" == "${match}" ]]; then
            _return=("${_return[@]:0:$index}" "${_return[@]:$(($index + 1))}")
           break
       fi
    done
}

# Auto modify the variable of $output.
# If $output have value = 'a.mp3' and there are file existing named a.mp3,
# the value will modify to `a (1).mp3' and auto increment.
PreventOverrideExistingFile() {
    basename=$(basename -- "$output")
    extension="${basename##*.}"
    if [[ "$extension" == "$basename" ]];then
        extension=
    fi
    filename="${basename%.*}"
    if [[ -e "$output" || -L "$output" ]] ; then
        i=1
        output="${filename} (${i})"
        [ -z "$extension" ] || output="$output"."$extension"
        while [[ -e "$output" || -L "$output" ]] ; do
            let i++
            output="${filename} (${i})"
            [ -z "$extension" ] || output="$output"."$extension"
        done
    fi
}

# How to use this command.
Usage () {
    cat <<- 'EOF' >&2
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
      youtube-dl "$url_download" --no-playlist --format mp4 \
      --write-all-thumbnails
   youtube-dl referer
      youtube-dl --add-header "Referer: $url_front_page" --no-playlist \
      --format mp4 --write-all-thumbnails "$url_download"

Options.
   -i, --include
        Shell script that will be included to execute before download execution.
        Use it to override any variable.

Note.
   The variable "$output" is not mandatory, and will be autopopulate with the
   date if empty or use the title of "$url_front_page" if any.

Version 0.1
EOF
    exit 1
}

# Memberikan warna kuning pada variable.
ColorizeCommandString() {
    [ -n "$2" ] && echo -n "$2"
    local string="$1"
    string=$(echo "$string" | sed -E "s|\\\$(\w+)|\\\e\[33m\$\1\\\e\[39m|g")
    echo -e "$string"
}

if [ "$1" == '' ];then
    Usage
fi

if [[ -n "$include" && ! -f "$include" ]];then
    echo "File $include not exists." >&2
    exit 1
fi

title=$(echo -e "\e[32m""Download Dialog.""\e[39m")
# Populate variable.
list_optional=()
list_mandatory=()
case "$1" in
    curl)
        case "$2" in
            saveas)
                case "$3" in
                    referer)
                        command_string='curl -L -H "Referer: $url_front_page" -o "$output" "$url_download"'
                        # subtitle=$(echo -e " "curl -L -H \"Referer: "\e[33m"\$url_front_page"\e[39m"\" -o \""\e[33m"\$output"\e[39m"\" \""\e[33m"\$url_download"\e[39m"\")
                        subtitle=$(ColorizeCommandString "$command_string" " ")
                        list_mandatory+=(url_front_page url_download)
                        list_optional+=(output)
                        ;;
                    *)
                        command_string='curl -L -H "Referer: $url_front_page" -o "$output" "$url_download"'
                        # subtitle=$(echo -e " "curl -L -o \""\e[33m"\$output"\e[39m"\" \""\e[33m"\$url_download"\e[39m"\")
                        subtitle=$(ColorizeCommandString "$command_string" " ")
                        list_mandatory+=(url_download)
                        list_optional+=(output)
                esac
                ;;
            *)
                command_string='curl -L -O -J "$url_download"'
                # subtitle=$(echo -e " "curl -L -O -J \""\e[33m"\$url_download"\e[39m"\")
                subtitle=$(ColorizeCommandString "$command_string" " ")
                list_mandatory+=(url_download)
        esac
        ;;
    wget)
        case "$2" in
            saveas)
                command_string='wget -O "$output" "$url_download"'
                # subtitle=$(echo -e " "wget -O \""\e[33m"\$output"\e[39m"\" \""\e[33m"\$url_download"\e[39m"\")
                subtitle=$(ColorizeCommandString "$command_string" " ")
                list_mandatory+=(url_download)
                list_optional+=(output)
                ;;
            *)
                command_string='wget "$url_download"'
                # subtitle=$(echo -e " "wget \""\e[33m"\$url_download"\e[39m"\")
                subtitle=$(ColorizeCommandString "$command_string" " ")
                list_mandatory+=(url_download)
        esac
        ;;
    youtube-dl)
        case "$2" in
            referer)
                command_string='youtube-dl --add-header "Referer: $url_front_page" --no-playlist --format mp4 --write-all-thumbnails "$url_download"'
                subtitle=$(ColorizeCommandString "$command_string" " ")
                list_mandatory+=(url_download)
                list_optional+=(output)
                ;;
            *)
                command_string='youtube-dl "$url_download" --no-playlist --format mp4 --write-all-thumbnails'
                subtitle=$(ColorizeCommandString "$command_string" " ")
                list_mandatory+=(url_download)
        esac
        ;;
    *)
        Usage
esac

# Merge variable.
list_all=("${list_mandatory[@]}" "${list_optional[@]}")
list_mandatory_empty=("${list_mandatory[@]}")
# Sef flag.
if ArraySearch "url_download" list_all[@];then
    display_url_download=1
fi
if ArraySearch "output" list_all[@];then
    display_output=1
fi
if ArraySearch "url_front_page" list_all[@];then
    display_url_front_page=1
fi

finish=
which_display=all
until [[ $finish == 1 ]]; do
    clear
    [ -n "$title" ] && echo "$title"
    [ -n "$subtitle" ] && echo "$subtitle"
    # url_download
    if [[ $display_url_download == 1 ]];then
        label="Input URL for Download."
        is_display=
        if [[ $which_display == all ]];then
            is_display=1
        elif [[ $which_display == empty_only && -z "$url_download" ]];then
            is_display=1
        elif [[ $which_display == required_only && -z "$url_download" ]];then
            if ArraySearch "url_download" list_mandatory[@];then
                echo -ne "\e[31m""Required.""\e[39m"" "
                is_display=1
            fi
        fi
        if [[ $is_display == 1 ]];then
            echo -e "\e[36m""$label""\e[39m"
            if [[ -n "$url_download" ]];then
                    echo -e " "$'\e[33m'"\$url_download"$'\e[39m'": $url_download"
                    echo -e "\e[32m""Option:""\e[39m"
                    echo -e " ""\e[35m""[""\e[33m"e"\e[35m""]""\e[39m"" Edit"
                    echo -e " ""\e[35m""[""\e[33m"d"\e[35m""]""\e[39m"" Delete"
                    echo -e " ""\e[35m""[""\e[33m" "\e[35m""]""\e[39m"" Skip"
                    read -rsn1 -p $'\e[32m'"Select: "$'\e[39m' option
                    echo
                    if [[ $option == "e" ]];then
                        echo -e " ""\e[35m""[""\e[33m"e"\e[35m""]""\e[39m"" Edit"
                        # For WSL 2 or Cygwin.
                        command -v clip.exe >/dev/null && echo -n "$url_download" | clip.exe && echo -e "\e[36m""Copied current value to Clipboard.""\e[33m"
                        read -p " "$'\e[33m'"\$url_download"$'\e[39m'": " url_download
                    elif [[ $option == "d" ]];then
                        echo -e " ""\e[35m""[""\e[33m"d"\e[35m""]""\e[39m"" Delete"
                        url_download=
                    else
                        echo -e " ""\e[35m""[""\e[33m" "\e[35m""]""\e[39m"" Skip"
                    fi
            else
                read -p " "$'\e[33m'"\$url_download"$'\e[39m'": " url_download
            fi
        fi
        if ArraySearch "url_download" list_mandatory[@];then
            if [ -n "$url_download" ];then
                if ArraySearch "url_download" list_mandatory_empty[@];then
                    ArrayRemove "url_download" list_mandatory_empty[@]
                    list_mandatory_empty=("${_return[@]}")
                fi
            elif ! ArraySearch "url_download" list_mandatory_empty[@];then
                list_mandatory_empty+=(url_download)
            fi
        fi
    fi
    # url_front_page
    if [[ $display_url_front_page == 1 ]];then
        label="Input URL Front Page."
        is_display=
        if [[ $which_display == all ]];then
            is_display=1
        elif [[ $which_display == empty_only && -z "$url_front_page" ]];then
            is_display=1
        elif [[ $which_display == required_only && -z "$url_front_page" ]];then
            if ArraySearch "url_front_page" list_mandatory[@];then
                echo -ne "\e[31m""Required.""\e[39m"" "
                is_display=1
            fi
        fi
        if [[ $is_display == 1 ]];then
            echo -e "\e[36m""$label""\e[39m"
            if [[ -n "$url_front_page" ]];then
                    echo -e " "$'\e[33m'"\$url_front_page"$'\e[39m'": $url_front_page"
                    echo -e "\e[32m""Option:""\e[39m"
                    echo -e " ""\e[35m""[""\e[33m"e"\e[35m""]""\e[39m"" Edit"
                    echo -e " ""\e[35m""[""\e[33m"d"\e[35m""]""\e[39m"" Delete"
                    echo -e " ""\e[35m""[""\e[33m" "\e[35m""]""\e[39m"" Skip"
                    read -rsn1 -p $'\e[32m'"Select: "$'\e[39m' option
                    echo
                    if [[ $option == "e" ]];then
                        echo -e " ""\e[35m""[""\e[33m"e"\e[35m""]""\e[39m"" Edit"
                        # For WSL 2 or Cygwin.
                        command -v clip.exe >/dev/null && echo -n "$url_front_page" | clip.exe && echo -e "\e[36m""Copied current value to Clipboard.""\e[33m"
                        read -p " "$'\e[33m'"\$url_front_page"$'\e[39m'": " url_front_page
                    elif [[ $option == "d" ]];then
                        echo -e " ""\e[35m""[""\e[33m"d"\e[35m""]""\e[39m"" Delete"
                        url_front_page=
                    else
                        echo -e " ""\e[35m""[""\e[33m" "\e[35m""]""\e[39m"" Skip"
                    fi
            else
                read -p " "$'\e[33m'"\$url_front_page"$'\e[39m'": " url_front_page
            fi
        fi
        if ArraySearch "url_front_page" list_mandatory[@];then
            if [ -n "$url_front_page" ];then
                if ArraySearch "url_front_page" list_mandatory_empty[@];then
                    ArrayRemove "url_front_page" list_mandatory_empty[@]
                    list_mandatory_empty=("${_return[@]}")
                fi
            elif ! ArraySearch "url_front_page" list_mandatory_empty[@];then
                list_mandatory_empty+=(url_front_page)
            fi
        fi
    fi
    # output
    if [[ $display_output == 1 ]];then
        label="Output filename."
        is_display=
        if [[ $which_display == all ]];then
            is_display=1
        elif [[ $which_display == empty_only && -z "$output" ]];then
            is_display=1
        elif [[ $which_display == required_only && -z "$output" ]];then
            if ArraySearch "output" list_mandatory[@];then
                echo -ne "\e[31m""Required.""\e[39m"" "
                is_display=1
            fi
        fi
        if [[ $is_display == 1 ]];then
            echo -e "\e[36m""$label""\e[39m"
            if [[ -n "$output" ]];then
                    echo -e " "$'\e[33m'"\$output"$'\e[39m'": $output"
                    echo -e "\e[32m""Option:""\e[39m"
                    echo -e " ""\e[35m""[""\e[33m"e"\e[35m""]""\e[39m"" Edit"
                    echo -e " ""\e[35m""[""\e[33m"d"\e[35m""]""\e[39m"" Delete"
                    echo -e " ""\e[35m""[""\e[33m" "\e[35m""]""\e[39m"" Skip"
                    read -rsn1 -p $'\e[32m'"Select: "$'\e[39m' option
                    echo
                    if [[ $option == "e" ]];then
                        echo -e " ""\e[35m""[""\e[33m"e"\e[35m""]""\e[39m"" Edit"
                        # For WSL 2 or Cygwin.
                        command -v clip.exe >/dev/null && echo -n "$output" | clip.exe && echo -e "\e[36m""Copied current value to Clipboard.""\e[33m"
                        read -p " "$'\e[33m'"\$output"$'\e[39m'": " output
                    elif [[ $option == "d" ]];then
                        echo -e " ""\e[35m""[""\e[33m"d"\e[35m""]""\e[39m"" Delete"
                        output=
                    else
                        echo -e " ""\e[35m""[""\e[33m" "\e[35m""]""\e[39m"" Skip"
                    fi
            else
                read -p " "$'\e[33m'"\$output"$'\e[39m'": " output
            fi
        fi
        if ArraySearch "output" list_mandatory[@];then
            if [ -n "$output" ];then
                if ArraySearch "output" list_mandatory_empty[@];then
                    ArrayRemove "output" list_mandatory_empty[@]
                    list_mandatory_empty=("${_return[@]}")
                fi
            elif ! ArraySearch "output" list_mandatory_empty[@];then
                list_mandatory_empty+=(output)
            fi
        fi
    fi
    # Preview
    clear
    [ -n "$title" ] && echo "$title"
    [ -n "$subtitle" ] && echo "$subtitle"
    echo -e "\e[32m""Preview.""\e[39m"
    if [[ $display_url_download == 1 ]];then
        echo -e " ""\e[33m"\$url_download"\e[39m"": $url_download"
    fi
    if [[ $display_url_front_page == 1 ]];then
        echo -e " ""\e[33m"\$url_front_page"\e[39m"": $url_front_page"
    fi
    if [[ $display_output == 1 ]];then
        echo -e " ""\e[33m"\$output"\e[39m"": $output"
    fi
    echo -e "\e[32m""Option:""\e[39m"
    echo -e " ""\e[35m""[""\e[33m"a"\e[35m""]""\e[39m"" Edit all"
    echo -e " ""\e[35m""[""\e[33m"e"\e[35m""]""\e[39m"" Edit empty only"
    echo -e " ""\e[35m""[""\e[33m" "\e[35m""]""\e[39m"" Finish"
    read -rsn1 -p $'\e[32m'"Select: "$'\e[39m' option
    echo
    if [[ $option == "a" ]];then
        echo -e " ""\e[35m""[""\e[33m"a"\e[35m""]""\e[39m"" Edit all"
        which_display=all
    elif [[ $option == "e" ]];then
        echo -e " ""\e[35m""[""\e[33m"e"\e[35m""]""\e[39m"" Edit empty only"
        which_display=empty_only
    else
        echo -e " ""\e[35m""[""\e[33m" "\e[35m""]""\e[39m"" Finish"
        if [[ ${#list_mandatory_empty[@]} == 0 ]];then
            finish=1
        else
            which_display=required_only
        fi
    fi
done

# Output is optional.
# Populate value for $output if empty.
if [[ $display_output == 1 && -z "$output" ]];then
    if [[ $display_url_front_page == 1 && -n "$url_front_page" ]];then
        unsanitized_output=$(curl -s -L "$url_front_page" | grep -o -E "<title>.*</title>" | sed -E "s/<title>(.*)<\/title>/\1/g")
        output=$(sed 's/[^'"'"'!@#$%^&\.,\+\{\};\[\]\(\)0123456789abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ_-]/_/g' <<< "$unsanitized_output" | sed -E 's/_+/_/g')
    fi
    [ -z "$output" ] && output=$(date +%Y%m%d%H%M%S)
    PreventOverrideExistingFile
fi

# Override variable.
if [ -f "$include" ];then
    source "$include"
fi

# The Last.
if [[ $display_url_download == 1 ]];then
    command_string=$(echo "$command_string" | sed "s|"'$url_download'"|$url_download|g")
fi
if [[ $display_url_front_page == 1 ]];then
    command_string=$(echo "$command_string" | sed "s|"'$url_front_page'"|$url_front_page|g")
fi
if [[ $display_output == 1 ]];then
    command_string=$(echo "$command_string" | sed "s|"'$output'"|$output|g")
fi
clear
echo "$title"
echo " ""$command_string"
echo -e "\e[32m""Option:""\e[39m"
echo -e " ""\e[35m""[""\e[33m"Ctrl+c"\e[35m""]""\e[39m"" Cancel"
echo -e " ""\e[35m""[""\e[33m"Enter "\e[35m""]""\e[39m"" Execute"
read -rsn1 -p $'\e[32m'"Select: "$'\e[39m' option
[ -z "$option" ] && echo "$command_string" | sh
