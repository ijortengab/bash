#!/bin/bash

# Original arguments.
ORIGINAL_ARGUMENTS=("$@")

# Temporary variable.
_new_arguments=()
_n=

# Processing standalone options.
while [[ $# -gt 0 ]]; do
    case "$1" in
        # flag
        -4)
            _4=1
            shift
            ;;
        # value
        -l=*)
            l="${1#*=}"
            shift
            ;;
        -l)
            if [[ ! $2 == "" && ! $2 =~ ^-[^-] ]];then
                l="$2"
                shift
            else
                echo "Option $1 requires an argument." >&2
            fi
            shift
            ;;
        # multivalue
        -o=*)
            o+=("${1#*=}")
            shift
            ;;
        -o)
            if [[ ! $2 == "" && ! $2 =~ ^-[^-] ]];then
                o+=("$2")
                shift
            else
                echo "Option $1 requires an argument." >&2
            fi
            shift
            ;;
        # increment
        -v)
            v="$((v+1))"
            shift
            ;;
        --)
            while [[ $# -gt 0 ]]; do
                case "$1" in
                    *)
                        _new_arguments+=("$1")
                        shift
                        ;;
                esac
            done
            ;;
        --[^-]*)
            echo "Invalid option: $1" >&2
            shift
            ;;
        *)
            while [[ $# -gt 0 ]]; do
                case "$1" in
                    *)
                        _new_arguments+=("$1")
                        shift
                        ;;
                esac
            done
            ;;
    esac
done

set -- "${_new_arguments[@]}"

# Truncate.
_new_arguments=()

# Processing compiled single character options.
while [[ $# -gt 0 ]]; do
    case "$1" in
        -[^-]*)
            OPTIND=1
            while getopts ":4l:o:v" opt; do
                case $opt in
                    # flag
                    4)
                        _4=1
                        ;;
                    # value
                    l)
                        l="$OPTARG"
                        ;;
                    # multivalue
                    o)
                        o+=("$OPTARG")
                        ;;
                    # increment
                    v)
                        v="$((v+1))"
                        ;;
                    \?)
                        echo "Invalid option: -$OPTARG" >&2
                        ;;
                    :) echo "Option -$OPTARG requires an argument." >&2 ;;
                esac
            done
            _n="$((OPTIND-1))"
            _n=${!_n}
            shift "$((OPTIND-1))"
            if [[ "$_n" == '--' ]];then
                while [[ $# -gt 0 ]]; do
                    case "$1" in
                        *)
                            _new_arguments+=("$1")
                            shift
                            ;;
                    esac
                done
            fi
            ;;
        --)
            shift
            while [[ $# -gt 0 ]]; do
                case "$1" in
                    *)
                        _new_arguments+=("$1")
                        shift
                        ;;
                esac
            done
            ;;
        *)
            while [[ $# -gt 0 ]]; do
                case "$1" in
                    *)
                        _new_arguments+=("$1")
                        shift
                        ;;
                esac
            done
            ;;
    esac
done

set -- "${_new_arguments[@]}"

unset _new_arguments
unset _n
# End of generated code by CodeGeneratorParseOptions().
