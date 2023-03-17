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

echo '[notice]' Process ID:"$$". >&2
echo '[notice]' PID file:"$pidfile". >&2

basename=$(basename $0)

getPid() {
    if [[ $(uname) == "Linux" ]];then
        # pid=$(ps aux | grep "$2" | grep -v grep | awk '{print $2}')
        [ -z "$USER" ] && USER=$(whoami)
        pid=$(ps -u $USER -U $USER x | grep "$1" | grep -v grep | grep -v "$basename" | grep "$2" | awk '{print $1}')
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
    echo '[cleaning]' Triggered. >&2
    pid=$(getPid "$command" "$CMD")
    if [[ $pid == '' ]];then
        echo '[cleaning]' PID not found. >&2
    else
        echo '[cleaning]' Kill PID $pid. >&2
        kill $pid
    fi
    rm "$pidfile"
    exit
}
trap cleaning SIGTERM
trap cleaning SIGINT

declare -i count
count=0
while true; do
    pid=$(getPid "$command" "$CMD")
    if [[ $pid == '' ]];then
        echo "$CMD" >&2
        echo "$CMD" | sh
        echo Exit code: $? >&2
        pid=$(getPid "$command" "$CMD")
    fi
    if [[ $pid == '' ]];then
        count+=1
        echo PID not found '('$count')'. >&2
        if [ $count -eq 60 ];then
            echo '[notice] Timeout, wait a minute.' >&2
            echo '[notice] Stop process with execute: `'kill $$'`.' >&2
            sleep 59
            count=0
        fi
        sleep 1
    else
        echo -n 'PID: ' >&2
        echo $pid
        while kill -0 $pid 2>/dev/null
        do
            sleep 60
        done
        echo PID $pid was terminated. >&2
    fi
done
