#!/bin/bash

_new_arguments=()

while [[ $# -gt 0 ]]; do
    case "$1" in
        --file-exists=*|-fe=*) file_exists+=("${1#*=}"); shift ;;
        --file-exists|-fe) if [[ ! $2 == "" && ! $2 =~ ^-[^-] ]]; then file_exists+=("$2"); shift; fi; shift ;;
        --file-not-exists=*|-fne=*) file_not_exists+=("${1#*=}"); shift ;;
        --file-not-exists|-fne) if [[ ! $2 == "" && ! $2 =~ ^-[^-] ]]; then file_not_exists+=("$2"); shift; fi; shift ;;
        --output=*|-o=*) output="${1#*=}"; shift ;;
        --output|-o) if [[ ! $2 == "" && ! $2 =~ ^-[^-] ]]; then output="$2"; shift; fi; shift ;;
        *) _new_arguments+=("$1"); shift ;;
    esac
done

set -- "${_new_arguments[@]}"

_new_arguments=()

while [[ $# -gt 0 ]]; do
    case "$1" in
        -[^-]*) OPTIND=1
            while getopts ":o:" opt; do
                case $opt in
                    o) output="$OPTARG" ;;
                esac
            done
            shift "$((OPTIND-1))"
            ;;
        *) _new_arguments+=("$1"); shift ;;
    esac
done

set -- "${_new_arguments[@]}"

unset _new_arguments

_echo() {
    echo -n "$1"
}
_break() {
    echo
}
yellowL() {
    echo -ne "\e[93m"
}
greenL() {
    echo -ne "\e[92m"
}
redL() {
    echo -ne "\e[91m"
}
magentaL() {
    echo -ne "\e[95m"
}
white() {
    echo -ne "\e[39m"
}

if [[ ! $1 == "" ]];then
    eval _output=\$\("$1"\)
    _result=$?
    yellowL; _echo "---"; white; _break;
    yellowL; _echo "$1"; white; _break;
    yellowL; _echo "---"; white; _break;
    if [[ $_result == 0 ]];then
        greenL; _echo "Success."; white; _echo " Command return: $_result"; _break;
    else
        redL; _echo "Error."; white; _echo " Command return: $_result"; _break;
    fi
    # Check Output.
    if [[ ! $output == "" ]];then
        if [[ "$output" == "$_output" ]];then
            greenL; _echo "Success."; white ; _echo " Output match:"; _break;
            magentaL; _echo "$_output"; white; _break
        else
            redL; _echo "Error."; white ; _echo " Output not match:"; _break;
            magentaL; _echo "$_output"; white; _break
        fi
    fi
    # Check File Exists.
    if [[ ${#file_exists[@]} -gt 0 ]];then
        for e in "${file_exists[@]}"; do
            if [ -f "$e" ];then
                   greenL; _echo "Success."; white ; _echo " File exists:"; _echo " $e"; _break
            else
                    redL; _echo "Error."; white ; _echo " File not exists:"; _echo " $e"; _break
            fi
        done
    fi
    # Check File Is Not Exists.
    if [[ ${#file_not_exists[@]} -gt 0 ]];then
        for e in "${file_not_exists[@]}"; do
            if [ ! -f "$e" ];then
                   greenL; _echo "Success."; white ; _echo " File not exists:"; _echo " $e"; _break
            else
                    redL; _echo "Error."; white ; _echo " File exists:"; _echo " $e"; _break
            fi
        done
    fi
    _break
fi
