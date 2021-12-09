#!/bin/bash
#
# Useful for creating tunnel with ssh.

if [[ -z "$1" ]];then
    echo 'Usage: command-keep-alive.sh <command> [<pidfile>]'
    exit
fi
if [[ -z "$2" ]];then
    pidfile=/tmp/$(mktemp command-keep-alive.XXXXXX.pid)
else
    pidfile="$2"
fi

echo $$ > "$pidfile"

getPid() {
    if [[ $(uname) == "Linux" ]];then
        pid=$(ps aux | grep "$2" | grep -v grep | awk '{print $2}')
        echo $pid
    elif [[ $(uname | cut -c1-6) == "CYGWIN" ]];then
        local pid command ifs
        ifs=$IFS
        ps -s | grep "$1" | awk '{print $1}' | while IFS= read -r pid; do\
            command=$(cat /proc/${pid}/cmdline | tr '\0' ' ')
            command=$(echo "$command" | sed 's/\ $//')
            IFS=$ifs
            if [[ "$command" == "$2" ]];then
                echo $pid
                break
            fi
        done
        IFS=$ifs
    fi
}

CMD="$1"
command=$(echo "$CMD" | cut -d' ' -f1)
cleaning() {
    echo Cleaning triggered. >&2
    pid=$(getPid "$command" "$CMD")
    if [[ $pid == '' ]];then
        echo PID not found. >&2
    else
        echo Cleaning PID $pid. >&2
        kill $pid
    fi
    rm "$pidfile"
    exit
}
trap cleaning SIGTERM
trap cleaning SIGINT
echo "$CMD" >&2
while true; do
    pid=$(getPid "$command" "$CMD")
    if [[ $pid == '' ]];then
        echo "$CMD" | sh
        pid=$(getPid "$command" "$CMD")
    fi
    if [[ $pid == '' ]];then
        echo PID not found. >&2
    else
        echo -n PID: >&2
        echo $pid
        while kill -0 $pid 2>/dev/null
        do
            sleep .1
        done
        echo PID $pid was terminated. >&2
    fi
done
