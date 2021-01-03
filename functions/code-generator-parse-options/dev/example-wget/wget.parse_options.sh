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
        --help|-h)
            help=1
            shift
            ;;
        # flag
        --version|-V)
            version=1
            shift
            ;;
        # value
        --append-output=*|-a=*)
            append_output="${1#*=}"
            shift
            ;;
        --append-output|-a)
            if [[ ! $2 == "" && ! $2 =~ ^-[^-] ]];then
                append_output="$2"
                shift
            else
                echo "Option $1 requires an argument." >&2
            fi
            shift
            ;;
        # flag
        --background|-b)
            background=1
            shift
            ;;
        # flag
        --debug|-d)
            debug=1
            shift
            ;;
        # multivalue
        --execute=*|-e=*)
            execute+=("${1#*=}")
            shift
            ;;
        --execute|-e)
            if [[ ! $2 == "" && ! $2 =~ ^-[^-] ]];then
                execute+=("$2")
                shift
            else
                echo "Option $1 requires an argument." >&2
            fi
            shift
            ;;
        # flag
        --no-host-directories|-nH)
            no_host_directories=1
            shift
            ;;
        # value
        --output-document=*|-O=*)
            output_document="${1#*=}"
            shift
            ;;
        --output-document|-O)
            if [[ ! $2 == "" && ! $2 =~ ^-[^-] ]];then
                output_document="$2"
                shift
            else
                echo "Option $1 requires an argument." >&2
            fi
            shift
            ;;
        # value
        --output-file=*|-o=*)
            output_file="${1#*=}"
            shift
            ;;
        --output-file|-o)
            if [[ ! $2 == "" && ! $2 =~ ^-[^-] ]];then
                output_file="$2"
                shift
            else
                echo "Option $1 requires an argument." >&2
            fi
            shift
            ;;
        # flag
        --quiet|-q)
            quiet=1
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
            _new_arguments+=("$1")
            shift
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
            while getopts ":hVa:bde:O:o:q" opt; do
                case $opt in
                    # flag
                    h)
                        help=1
                        ;;
                    # flag
                    V)
                        version=1
                        ;;
                    # value
                    a)
                        append_output="$OPTARG"
                        ;;
                    # flag
                    b)
                        background=1
                        ;;
                    # flag
                    d)
                        debug=1
                        ;;
                    # multivalue
                    e)
                        execute=("$OPTARG")
                        ;;
                    # value
                    O)
                        output_document="$OPTARG"
                        ;;
                    # value
                    o)
                        output_file="$OPTARG"
                        ;;
                    # flag
                    q)
                        quiet=1
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
            _new_arguments+=("$1")
            shift
            ;;
    esac
done

set -- "${_new_arguments[@]}"

unset _new_arguments
unset _n
# End of generated code by CodeGeneratorParseOptions().
