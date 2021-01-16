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
