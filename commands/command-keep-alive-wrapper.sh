#!/bin/bash

# Prerequisite.
[ -f "$0" ] || { echo -e "\e[91m" "Cannot run as dot command. Hit Control+c now." "\e[39m"; read; exit 1; }

# Parse arguments. Generated by parse-options.sh
_new_arguments=()
while [[ $# -gt 0 ]]; do
    case "$1" in
        --help|-h) help=1; shift ;;
        --version|-v) version=1; shift ;;
        --action=*) action="${1#*=}"; shift ;;
        --action) if [[ ! $2 == "" && ! $2 =~ ^-[^-] ]]; then action="$2"; shift; fi; shift ;;
        --daemon|-d) action=daemon; shift ;;
        --is-exists|-e) action=is_exists; shift ;;
        --run|-r) action=run; shift ;;
        --[^-]*) shift ;;
        *) _new_arguments+=("$1"); shift ;;
    esac
done
set -- "${_new_arguments[@]}"
_new_arguments=()
while [[ $# -gt 0 ]]; do
    case "$1" in
        -[^-]*) OPTIND=1
            while getopts ":hvder" opt; do
                case $opt in
                    h) help=1 ;;
                    v) version=1 ;;
                    d) action=daemon ;;
                    e) action=is_exists ;;
                    r) action=run ;;
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
command="$1"; shift
pid_file="$1"; shift
timeout_trigger_command="$1"; shift

# Functions.
printVersion() {
    echo '0.1.0'
}
printHelp() {
    cat << 'EOF'
Usage: command-keep-alive-wrapper.sh <command> <pid_file> [timeout_trigger_command] [options]

Options:
   --run ^
        Alias of --action=run
   --is-exists ^
        Alias of --action=is_exists
   --daemon ^
        Alias of --action=daemon
   --action
        Set the action of this wrapper (Default is run).

Global Options:
   --version
        Print version of this script.
   --help
        Show this help.

Dependency:
   command-keep-alive.sh

Download:
   [command-keep-alive.sh](https://github.com/ijortengab/bash/raw/master/commands/command-keep-alive.sh)
EOF
}

# Help and Version.
[ -n "$version" ] && { printVersion; exit 1; }
[ -z "$command" ] && { printHelp; exit 1; }
[ -z "$pid_file" ] && { printHelp; exit 1; }
[ -n "$help" ] && { printHelp; exit 1; }

# Dependency.
while IFS= read -r line; do
    command -v "${line}" >/dev/null || { echo -e "\e[91m""Unable to proceed, ${line} command not found." "\e[39m"; exit 1; }
done <<< `printHelp | sed -n '/^Dependency:/,$p' | sed -n '2,/^$/p' | sed 's/^ *//g'`

# Require, validate, and populate value.
pid_exists=
pid=
[ -f "$pid_file" ] && read pid <"$pid_file"
if [ -n "$pid" ];then
    kill -0 $pid 2>/dev/null && pid_exists=1
fi
[ -n "$action" ] || action=run

# Execute.
case "$action" in
    is_exists)
        if [ -n "$pid_exists" ];then
            echo 1
            exit 0
        else
            exit 2
        fi
        ;;
    daemon)
        if [ -z "$pid_exists" ];then
            command-keep-alive.sh "$command" --pid-file="$pid_file" --timeout-trigger-command="$timeout_trigger_command" 2>&1 &
        fi
        ;;
    run)
        if [ -z "$pid_exists" ];then
            command-keep-alive.sh "$command" --pid-file="$pid_file" --timeout-trigger-command="$timeout_trigger_command" 2>&1
        else
            echo $pid
        fi
        ;;
esac

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
# )
# VALUE=(
# --action
# )
# MULTIVALUE=(
# )
# FLAG_VALUE=(
# )
# CSV=(
    # short:-d,long:--daemon,parameter:action,type:flag,flag_option:true=daemon
    # short:-e,long:--is-exists,parameter:action,type:flag,flag_option:true=is_exists
    # short:-r,long:--run,parameter:action,type:flag,flag_option:true=run
# )
# EOF
# clear
