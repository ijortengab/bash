#!/bin/bash

# Prerequisite.
[ -f "$0" ] || { echo -e "\e[91m" "Cannot run as dot command. Hit Control+c now." "\e[39m"; read; exit 1; }

# Parse arguments. Generated by parse-options.sh
_new_arguments=()
while [[ $# -gt 0 ]]; do
    case "$1" in
        --help|-h) help=1; shift ;;
        --version|-v) version=1; shift ;;
        --daemon) daemon=1; shift ;;
        --[^-]*) shift ;;
        *) _new_arguments+=("$1"); shift ;;
    esac
done
set -- "${_new_arguments[@]}"
_new_arguments=()
while [[ $# -gt 0 ]]; do
    case "$1" in
        -[^-]*) OPTIND=1
            while getopts ":hv" opt; do
                case $opt in
                    h) help=1 ;;
                    v) version=1 ;;
                esac
            done
            shift "$((OPTIND-1))"
            ;;
        *) _new_arguments+=("$1"); shift ;;
    esac
done
set -- "${_new_arguments[@]}"
unset _new_arguments

# Operand.
pattern="$1"; shift
pid_file="$1"; shift
timeout_trigger_command="$1"; shift

# Functions.
printVersion() {
    echo '0.1.0'
}
printHelp() {
    cat << 'EOF'
Usage: ssh-keepalive.sh <pattern> <pid_file> [timeout_trigger_command] [options]

Global Options:
   --version
        Print version of this script.
   --help
        Show this help.

Dependency:
   ssh-command-generator.sh
   command-keep-alive-wrapper.sh
EOF
}

# Help and Version.
[ -n "$version" ] && { printVersion; exit 1; }
[ -z "$pattern" ] && { printHelp; exit 1; }
[ -z "$pid_file" ] && { printHelp; exit 1; }
[ -n "$help" ] && { printHelp; exit 1; }

# Dependency.
while IFS= read -r line; do
    command -v "${line}" >/dev/null || { echo -e "\e[91m""Unable to proceed, ${line} command not found." "\e[39m"; exit 1; }
done <<< `printHelp | sed -n '/^Dependency:/,$p' | sed -n '2,/^$/p' | sed 's/^ *//g'`

# Execute.
pattern+=.passwordless.keepalive.daemon
command=$(ssh-command-generator.sh "$pattern" )
if [ $? -gt 0 ];then
    exit 1
fi
[ -n "$daemon" ] && isdaemon='--daemon ' || isdaemon=''
command-keep-alive-wrapper.sh $isdaemon "$command" "$pid_file" "$timeout_trigger_command"

# parse-options.sh \
# --without-end-options-double-dash \
# --compact \
# --clean \
# --no-hash-bang \
# --no-original-arguments \
# --no-error-invalid-options \
# --no-error-require-arguments << EOF | clip
# FLAG=(
# '--version|-v'
# '--help|-h'
# --daemon
# )
# VALUE=(
# )
# MULTIVALUE=(
# )
# FLAG_VALUE=(
# )
# CSV=(
# )
# EOF
# clear