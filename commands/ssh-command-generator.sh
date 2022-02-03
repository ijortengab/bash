#!/bin/bash

# Jika ada extension .sh, maka hapus.
filename=$(basename "$0")
if [[ ${filename:(-3)} == '.sh' ]];then
    filename=${filename:0:(-3)}
fi

if [[ "$filename" == 'ssh-command-generator' ]];then
    Usage() {
        cat <<EOL >&2
Usage:

  ssh-command-generator.sh list
  ssh-command-generator.sh create <filename>
  ssh-command-generator.sh rename <filename> <newfilename>
  ssh-command-generator.sh delete <filename>

Then use <filename> as a command to generate and execute ssh command.

Example of <filename>:
 - pcfaris-dpf.lport-9090
 - pcdina-lpf.rport-rdp.lport-11300.triggerusehost
 - pcpuji-lpf.rport-rdp.lport-10302.triggerusehost.from-pchadi
 - pcfarah-lpf.rport-vnc.lport-10901.noloopback
 - pcfaris-lpf.rport-ssh.lport-10002
 - pcroni-lpf.rport-openvpn.lport-11103.noloopback.triggerusehost
 - cctv3-lpf.rport-http.lport-20102.jump-p.from-pcpuji
 - s-lpf.rport-mysql.lport-30100

This script usually to create ssh tunneling with local/remote/dynamic port forwarding.
EOL
    }
    case $1 in
        list)
            source="$0"
            dirname=$(dirname "$0")
            find -L "$dirname" -samefile "$0" | grep -v ssh-command-generator.sh
        ;;
        create)
            [ -z "$2" ] && { echo "Missing Argument." >&2; exit 1; }
            source="$0"
            dirname=$(dirname "$0")
            target="${dirname}/$2"
            echo ln -sf \""$source"\" \""$target"\"
            ln -sf "$source" "$target"
            echo Link created. >&2
        ;;
        delete)
            [ -z "$2" ] && { echo "Missing Argument." >&2; exit 1; }
            source="$0"
            dirname=$(dirname "$0")
            target="${dirname}/$2"
            if [[ -h "$target" ]];then
                echo rm -rf \""$target"\"
                rm -rf "$target"
                echo Link removed. >&2
            else
                echo Link not found. >&2
            fi
        ;;
        rename)
            [ -z "$2" ] && { echo "Missing Argument." >&2; exit 1; }
            [ -z "$3" ] && { echo "Missing Argument." >&2; exit 1; }
            source="$0"
            dirname=$(dirname "$0")
            target="${dirname}/$2"
            target_new="${dirname}/$3"
            if [[ -h "$target" ]];then
                echo mv \""$target"\" \""$target_new"\"
                mv "$target" "$target_new"
                echo Link renamed. >&2
            else
                echo Link not found. >&2
            fi
        ;;
        *)
            Usage
    esac
    exit
fi

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

# https://stackoverflow.com/questions/12779134/parsing-ssh-config-for-proxy-information
getIP() {
    awk -v H="$1" '
    tolower($1) == "host" { m=$2 == H }
    tolower($1) == "hostname" && m{ print $2 }
    ' ~/.ssh/config
}

# Variable diambil dari filename.
head=$(echo "$filename" | cut -d'.' -f 1)
host=$(echo "$head" | cut -d'-' -f 1)
variant=$(echo "$head" | cut -d'-' -f 2)

# Spasi harus single agar sama dengan isi di file /proc/${pid}/cmdline
CMD=$(cat <<- EOL
ssh \
-o ServerAliveInterval=10 -o ServerAliveCountMax=2 \
OPTION \
HOST
EOL
)

case "$variant" in
    lpf)
        OPTION=
        remote_port=$(grep -Eo '\.rport-[^.]+' <<< "$filename" | sed -E 's/\.rport-(.*)/\1/')
        case $remote_port in
            http) remote_port=80 ;;
            rdp) remote_port=3389 ;;
            vnc) remote_port=5900 ;;
            ssh) remote_port=22 ;;
            mysql) remote_port=3306 ;;
            openvpn) remote_port=1194 ;;
        esac
        local_port=$(grep -Eo '\.lport-[^.]+' <<< "$filename" | sed -E 's/\.lport-(.*)/\1/')
        from=$(grep -Eo '\.from-[^.]+' <<< "$filename" | sed -E 's/\.from-(.*)/\1/')
        jump=$(grep -Eo '\.jump-[^.]+' <<< "$filename" | sed -E 's/\.jump-(.*)/\1/')
        noloopback=$(grep -Eo '\.noloopback(\.|$)' <<< "$filename")
        ip="127.0.0.1"
        [ -n "$jump" ] && OPTION+="-J $jump "
        if [ -n "$noloopback" ];then
            # IP harus ada di ~/.ssh/config
            ip=$(getIP "$host")
            if [ -z "$ip" ];then
                echo IP Address for '"'$host'"' not found in ssh config. >&2
                ip="$host"
            fi
        fi
        HOST="$host"
        # Jika ada variable `from`, maka perlu dapatkan ip.
        if [ -n "$from" ];then
            HOST="$from"
            # IP harus ada di ~/.ssh/config
            ip=$(getIP "$host")
            # Jika tidak ada, gunakan host, semoga resolver dari `from`
            # mengenali IP dari host.
            if [ -z "$ip" ];then
                echo IP Address for '"'$host'"' not found in ssh config. >&2
                ip="$host"
            fi
        fi
        OPTION+="-fN -L $local_port:$ip:$remote_port"
        ;;
    dpf)
        local_port=$(grep -Eo '\.lport-[^.]+' <<< "$filename" | sed -E 's/\.lport-(.*)/\1/')
        HOST="$host"
        OPTION+="-fN -D $local_port"
        ;;
esac

CMD=$(sed 's|OPTION|'"$OPTION"'|' <<< "$CMD")
CMD=$(sed 's|HOST|'"$HOST"'|' <<< "$CMD")
pid=$(getPid ssh "$CMD")
echo "$CMD" >&2
if [[ $pid == '' ]];then
    echo "$CMD" | sh
    pid=$(getPid ssh "$CMD")
fi
echo -n PID: >&2
echo $pid

# Trigger.
case "$variant" in
    lpf)
        if [[ -n "$pid" ]];then
            ip="127.0.0.1"
            triggerusehost=$(grep -Eo '\.triggerusehost(\.|$)' <<< "$filename")
            [ -z "$triggerusehost" ] || ip="$host"
            trigger=$(grep -Eo '\.trigger-[^.]+' <<< "$filename" | sed -E 's/\.trigger-(.*)/\1/')
            [ -n "$trigger" ] || trigger=auto
            if [[ $trigger == no ]];then
                exit
            elif [[ $trigger == auto ]];then
                case "$remote_port" in
                    80) trigger=http;;
                    22) trigger=scp;;
                    5900) trigger=vnc;;
                    3389) trigger=rdp;;
                    1194) trigger=openvpn;;
                esac
            fi
            case $trigger in
                http)
                    echo cmd.exe /C start http://$ip:$local_port
                    cmd.exe /C start http://$ip:$local_port
                    ;;
                scp)
                    # Progra~2 = Program Files (x86)
                    echo cmd.exe /C start C:\\Progra~2\\WinSCP\\WinSCP.exe $ip:$local_port
                    cmd.exe /C start C:\\Progra~2\\WinSCP\\WinSCP.exe $ip:$local_port
                    ;;
                vnc)
                    # echo $USERPROFILE
                    # Progra~1 = Program Files
                    if [ -f "$USERPROFILE/.passwd.vnc" ];then
                        echo cmd.exe /C start C:\\Progra~1\\TightVNC\\tvnviewer.exe -host=$ip -port=$local_port -password=$(<$USERPROFILE/.passwd.vnc)
                        cmd.exe /C start C:\\Progra~1\\TightVNC\\tvnviewer.exe -host=$ip -port=$local_port -password=$(<$USERPROFILE/.passwd.vnc)
                    else
                        echo cmd.exe /C start C:\\Progra~1\\TightVNC\\tvnviewer.exe -host=$ip -port=$local_port
                        cmd.exe /C start C:\\Progra~1\\TightVNC\\tvnviewer.exe -host=$ip -port=$local_port
                    fi
                    ;;
                rdp)
                    echo cmd.exe /C start mstsc /v:$ip:$local_port
                    cmd.exe /C start mstsc /v:$ip:$local_port
                    ;;
                openvpn)
                    # Progra~1 = Program Files
                    echo cmd.exe /C start C:\\Progra~1\\OpenVPN\\bin\\openvpn-gui.exe --connect $ip-$local_port.ovpn
                    cmd.exe /C start C:\\Progra~1\\OpenVPN\\bin\\openvpn-gui.exe --connect $ip-$local_port.ovpn
                    ;;
            esac
        fi
        ;;
esac
