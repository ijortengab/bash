#!/bin/bash

# Jika ada extension .sh, maka hapus.
filename=$(basename "$0")
if [[ ${filename:(-3)} == '.sh' ]];then
    filename=${filename:0:(-3)}
fi

if [[ "$filename" == 'ssh' ]];then
    Usage() {
        cat <<EOL >&2
Usage:

  ssh.sh list|l
  ssh.sh create|c <filename>
  ssh.sh rename|r <filename> <newfilename>
  ssh.sh delete|d <filename>

Then use <filename> as a command to generate and execute ssh command.

Example of <filename>:
 - pil,go
 - pil,rpf.rport,12257.lport,22
 - pcfaris,dpf.lport,9090
 - pcdina,lpf.rport,rdp.lport,11300.triggerusehost
 - pcpuji,lpf.rport,rdp.lport,10302.triggerusehost.from,pchadi
 - pcfarah,lpf.rport,vnc.lport,10901.noloopback
 - pcfaris,lpf.rport,ssh.lport,10002
 - pcroni,lpf.rport,vpn.lport,11103.noloopback.triggerusehost
 - cctv3,lpf.rport,http.lport,20102.jump,p.from,pcpuji
 - s,lpf.rport,mysql.lport,30100
 - pcfaris,lpf.rport,33899.lport,10001.trigger,rdp
 - pcfaris,lpf.rport,ssh.lport,10002.trigger,no
 - pcroni,lpf.rport,9090.lport,11104.trigger,http.from,pcfaris

This script usually to create ssh tunneling with local/remote/dynamic port forwarding.
EOL
    }
    case $1 in
        list|l)
            source="$0"
            dirname=$(dirname "$0")
            find -L "$dirname" -samefile "$0" | grep -v ssh.sh
        ;;
        create|c)
            [ -z "$2" ] && { echo "Missing Argument." >&2; exit 1; }
            source="$0"
            dirname=$(dirname "$0")
            target="$2"
            local_port=$(grep -Eo '\.lport,[^.]+' <<< "$2" | sed -E 's/\.lport,(.*)/\1/')
            if [[ $local_port == 'auto' ]];then
                last=$(find -L "$dirname" -samefile "$0" | grep -v ssh.sh |  grep -o -P 'lport,\K(\d+)' | sort | tail -n1)
                [ -z "$last" ] && last=10000
                if [ $last -lt 10000 ];then
                    next=$(( last + 10000 ))
                else
                    next=$(( last + 1 ))
                fi
                target=$(sed "s/lport,auto/lport,${next}/"  <<< "$target")
            fi
            target="${dirname}/$target"
            echo ln -sf \""$source"\" \""$target"\"
            ln -sf "$source" "$target"
            echo Link created. >&2
        ;;
        delete|d)
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
        rename|r)
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

translatePort() {
    local port
    case $1 in
            http) port=80 ;;
            rdp) port=3389 ;;
            vnc) port=5900 ;;
            ssh) port=22 ;;
            mysql) port=3306 ;;
            vpn) port=1194 ;;
    esac
    [ -n "$port" ] && echo "$port" || echo "$1"
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
host=$(echo "$head" | cut -d',' -f 1)
variant=$(echo "$head" | cut -d',' -f 2)

# Spasi harus single agar sama dengan isi di file /proc/${pid}/cmdline
CMD=$(cat <<- EOL
ssh \
-o ServerAliveInterval=10 -o ServerAliveCountMax=2 \
-o PreferredAuthentications=publickey -o PasswordAuthentication=no \
OPTION \
HOST
EOL
)

case "$variant" in
    go)
        remote_port=22
        ip="$host"
        ;;
    lpf|rpf)
        OPTION=
        remote_port=$(grep -Eo '\.rport,[^.]+' <<< "$filename" | sed -E 's/\.rport,(.*)/\1/')
        remote_port=$(translatePort "$remote_port")
        local_port=$(grep -Eo '\.lport,[^.]+' <<< "$filename" | sed -E 's/\.lport,(.*)/\1/')
        local_port=$(translatePort "$local_port")
        from=$(grep -Eo '\.from,[^.]+' <<< "$filename" | sed -E 's/\.from,(.*)/\1/')
        jump=$(grep -Eo '\.jump,[^.]+' <<< "$filename" | sed -E 's/\.jump,(.*)/\1/')
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
        case "$variant" in
            lpf)
                OPTION+="-fN -L $local_port:$ip:$remote_port"
                ;;
            rpf)
                OPTION+="-fN -R $remote_port:$ip:$local_port"
        esac
        ;;
    dpf)
        local_port=$(grep -Eo '\.lport,[^.]+' <<< "$filename" | sed -E 's/\.lport,(.*)/\1/')
        HOST="$host"
        OPTION+="-fN -D $local_port"
        ;;
esac

case "$variant" in lpf|rpf|dpf)
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
esac

# Trigger.
case "$variant" in
    lpf)
        if [[ -n "$pid" ]];then
            ip="127.0.0.1"
            triggerusehost=$(grep -Eo '\.triggerusehost(\.|$)' <<< "$filename")
            [ -z "$triggerusehost" ] || ip="$host"
            target_port=$local_port
        fi
        ;;
    go)
        target_port=$remote_port
esac

if [[ -z "$target_port" ]];then
    exit
fi

trigger=$(grep -Eo '\.trigger,[^.]+' <<< "$filename" | sed -E 's/\.trigger,(.*)/\1/')
[ -n "$trigger" ] || trigger=auto
if [[ $trigger == no ]];then
    exit
elif [[ $trigger == auto ]];then
    case "$remote_port" in
        80) trigger=http;;
        22) trigger=scp;;
        5900) trigger=vnc;;
        3389) trigger=rdp;;
        1194) trigger=vpn;;
    esac
fi
case $trigger in
    http)
        echo cmd.exe /C start http://$ip:$target_port
        cmd.exe /C start http://$ip:$target_port
        ;;
    scp)
        # Progra~2 = Program Files (x86)
        # Simpan session di WinSCP dengan format host:port
        [ -f "/cygdrive/c/Program Files (x86)/WinSCP/WinSCP.exe" ] && {
            echo cmd.exe /C start C:\\Progra~2\\WinSCP\\WinSCP.exe $ip:$target_port
            cmd.exe /C start C:\\Progra~2\\WinSCP\\WinSCP.exe $ip:$target_port
        }
        [ -f "$USERPROFILE/AppData/Local/Programs/WinSCP/WinSCP.exe" ] && {
            echo cmd.exe /C start %USERPROFILE%\\AppData\\Local\\Programs\\WinSCP\\WinSCP.exe $ip:$target_port
            cmd.exe /C start %USERPROFILE%\\AppData\\Local\\Programs\\WinSCP\\WinSCP.exe $ip:$target_port
        }
        ;;
    vnc)
        # Progra~1 = Program Files
        # Simpan password di file "$USERPROFILE/.passwd.vnc"
        [ -f "/cygdrive/c/Program Files/TightVNC/tvnviewer.exe" ] && {
            args_other=
            if [ -f "$USERPROFILE/.passwd.vnc" ];then
                args_other=' -password='"$(<$USERPROFILE/.passwd.vnc)"
            fi
            echo cmd.exe /C start C:\\Progra~1\\TightVNC\\tvnviewer.exe -host=$ip -port=$target_port$args_other
            cmd.exe /C start C:\\Progra~1\\TightVNC\\tvnviewer.exe -host=$ip -port=$target_port$args_other
        }
        ;;
    rdp)
        echo cmd.exe /C start mstsc /v:$ip:$target_port
        cmd.exe /C start mstsc /v:$ip:$target_port
        ;;
    vpn)
        # Progra~1 = Program Files
        # Simpan config VPN dengan nama $ip-$target_port.ovpn
        [ -f "/cygdrive/c/Program Files/OpenVPN/bin/openvpn-gui.exe" ] && {
            echo cmd.exe /C start C:\\Progra~1\\OpenVPN\\bin\\openvpn-gui.exe --connect $ip-$target_port.ovpn
            cmd.exe /C start C:\\Progra~1\\OpenVPN\\bin\\openvpn-gui.exe --connect $ip-$target_port.ovpn
        }
        ;;
esac
