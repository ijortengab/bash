#!/bin/bash

ORIGINAL_ARGUMENTS=("$@")

_new_arguments=()
_n=

while [[ $# -gt 0 ]]; do
    case "$1" in
        -4) _4=1; shift ;;
        -l=*) l="${1#*=}"; shift ;;
        -l) if [[ ! $2 == "" && ! $2 =~ ^-[^-] ]]; then l="$2"; shift; else echo "Option $1 requires an argument." >&2; fi; shift ;;
        -o=*) o+=("${1#*=}"); shift ;;
        -o) if [[ ! $2 == "" && ! $2 =~ ^-[^-] ]]; then o+=("$2"); shift; else echo "Option $1 requires an argument." >&2; fi; shift ;;
        -v) v="$((v+1))"; shift ;;
        --)
            while [[ $# -gt 0 ]]; do
                case "$1" in
                    *) _new_arguments+=("$1"); shift ;;
                esac
            done
            ;;
        --[^-]*) echo "Invalid option: $1" >&2; shift ;;
        *)
            while [[ $# -gt 0 ]]; do
                case "$1" in
                    *) _new_arguments+=("$1"); shift ;;
                esac
            done
            ;;
    esac
done

set -- "${_new_arguments[@]}"

_new_arguments=()

while [[ $# -gt 0 ]]; do
    case "$1" in
        -[^-]*) OPTIND=1
            while getopts ":4l:o:v" opt; do
                case $opt in
                    4) _4=1 ;;
                    l) l="$OPTARG" ;;
                    o) o+=("$OPTARG") ;;
                    v) v="$((v+1))" ;;
                    \?) echo "Invalid option: -$OPTARG" >&2 ;;
                    :) echo "Option -$OPTARG requires an argument." >&2 ;;
                esac
            done
            _n="$((OPTIND-1))"
            _n=${!_n}
            shift "$((OPTIND-1))"
            if [[ "$_n" == '--' ]];then
                while [[ $# -gt 0 ]]; do
                    case "$1" in
                        *) _new_arguments+=("$1"); shift ;;
                    esac
                done
            fi
            ;;
        --) shift
            while [[ $# -gt 0 ]]; do
                case "$1" in
                    *) _new_arguments+=("$1"); shift ;;
                esac
            done
            ;;
        *)
            while [[ $# -gt 0 ]]; do
                case "$1" in
                    *) _new_arguments+=("$1"); shift ;;
                esac
            done
            ;;
    esac
done

set -- "${_new_arguments[@]}"

unset _new_arguments
unset _n

# Start developing

echo
echo 'Lorem ipsum dolor sit amet.'
echo
echo 'Lorem ipsum dolor sit amet.'
echo
