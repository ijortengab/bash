#!/bin/bash

# Parse arguments. Generated by parse-options.sh.
_new_arguments=()
while [[ $# -gt 0 ]]; do
    case "$1" in
        --help|-h) help=1; shift ;;
        --version|-v) version=1; shift ;;
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

# Functions.
printVersion() {
    echo '0.1.0'
}
printHelp() {
    cat << 'EOF'
Usage: ssh-command-generator.sh <pattern> [options]

Global Options:
   --version
        Print version of this script.
   --help
        Show this help.

Pattern format:
    key[,value][.key[,value]]...

Key and value available:
    from,<host>
    lpf,<host>
    rpf,<host>
    <host>,lpf The alias of from,<host>.lpf,localhost
    <host>,rpf The alias of from,<host>.rpf,localhost
    dport,<port> Destination port
    sport,<port> Souce port
    rport,<port> Remote port (relative version of dport and sport)
    lport,<port> Local port (relative version of dport and sport)
    timeout,<value>
    keepalive
    daemon
    o,<option>
    ip,<host>
    passwordless
    f,<flag>

Port alias:
    http alias of 80
    rdp alias of 3389
    vnc alias of 5900
    ssh alias of 22
    mysql alias of 3306
    vpn alias of 1194

Example:
    Open local port to access mysql port of remote.
        Execute this:
        ssh-command-generator.sh myserver,lpf.lport,10000.rport,mysql
        Command above will produce:
        ssh -L 10000:127.0.0.1:3306 myserver
        Notice: `myserver,lpf` is alias of `from,myserver.lpf,localhost`
                `mypc,rpf` is alias of `from,mypc.rpf,localhost`
    Open local port to access VNC of remote
        Execute this:
        ssh-command-generator.sh mypc,lpf.lport,15900.rport,vnc
        Command above will produce:
        ssh -L 15900:127.0.0.1:5900 mypc
        TightVNC Server will reject connection from loopback (127.0.0.1), so
        you have to add key `ip` to translate the host.
        Put information in $HOME/.ssh/config about your IP in LAN.
        ```
        Host mypc
            Hostname 192.168.100.101
        ```
        The Right way:
        ssh-command-generator.sh mypc,lpf.lport,15900.rport,vnc.ip,mypc
        Command above will produce:
        ssh -L 15900:192.168.100.101:5900 mypc
    Open local port to access http proxy from your VPS Server
        Execute this:
        ssh-command-generator.sh server1,lpf.lport,8888.rport,8888
        Command above will produce:
        ssh -L 8888:127.0.0.1:8888 server1
    Open local port to access web CCTV from your PC
        Execute this:
        ssh-command-generator.sh from,mypc.lpf,cctv1.lport,8080.rport,http.
        Command above will produce:
        ssh -L 8080:192.168.100.6:80 mypc
        Attention: The use of `from` key is always using the `ip` key
        automatically for all host tunneling.
        Put information in $HOME/.ssh/config about your IP of CCTV in LAN.
        ```
        Host cctv1
            Hostname 192.168.100.6
        ```
    Open remote port of server to access your local ssh port.
        Execute this:
        ssh-command-generator.sh server,rpf.lport,ssh.rport,2200
        Command above will produce:
        ssh -R 2200:127.0.0.1:22 server
    Open remote port of server to access your local ssh and http port.
        Execute this:
        ssh-command-generator.sh server,rpf.lport,ssh.rport,2200.lport,http.rport,8000
        Command above will produce:
        ssh -R 2200:127.0.0.1:22 -R 8000:127.0.0.1:80 server
EOF
}

# Help and Version.
[ -n "$version" ] && { printVersion; exit 1; }
[ -z "$pattern" ] && { printHelp; exit 1; }
[ -n "$help" ] && { printHelp; exit 1; }

# Functions.
ArraySearch() {
    local index match="$1"
    local source=("${!2}")
    for index in "${!source[@]}"; do
       if [[ "${source[$index]}" == "${match}" ]]; then
           _return=$index; return 0
       fi
    done
    return 1
}
getIP() {
    # https://stackoverflow.com/questions/12779134/parsing-ssh-config-for-proxy-information
    awk -v H="$1" '
    tolower($1) == "host" { m=$2 == H }
    tolower($1) == "hostname" && m{ print $2 }
    ' $HOME/.ssh/config
}
translatePort() {
    local port="$1"
    case "$port" in
        http) port=80 ;;
        rdp) port=3389 ;;
        vnc) port=5900 ;;
        ssh) port=22 ;;
        mysql) port=3306 ;;
        vpn) port=1194 ;;
    esac
    echo "$port"
}

# Require, validate, and populate value.
find=
host=
host_final=
lport=
rport=
register=()
host2ip=()
options=()
flag=()
string=${pattern%.} # remove suffix.

# Execute.
until [ -z "$string" ];do
    part=$(grep -Eo '^[^\.]+(\.|$)' <<< "$string")
    part_length=${#part}
    part=${part%.} # remove suffix.
    string=${string:$part_length}
    key=$(cut -d, -f1 <<< "$part")
    value=
    if [[ $part =~ , ]];then
        value=$(cut -d, -f2 <<< "$part")
    fi
    case "$find" in
        host)
            case "$value" in
                rpf|lpf)
                    host="$key"
                    what="$value"
                    find=port
                    ;;
            esac
            case "$key" in
                from)
                    host="$value"
                    if [ -n "$host_final" ];then
                        if [[ ! "$host" == "$host_final" ]];then
                            echo Syntax error. Key '`'from'`' can not more than one host.>&2 ; exit 1;
                        fi
                    fi
                    host_final="$value"
                    find=
            esac
            host="$key"
            ;;
        port)
            case "$key" in
                lport)
                    case "$what" in
                        lpf)
                            sport="$value"
                            find=rport
                            ;;
                        rpf)
                            dport="$value"
                            find=rport
                            ;;
                    esac
                    ;;
                rport)
                    case "$what" in
                        lpf)
                            dport="$value"
                            find=lport
                            ;;
                        rpf)
                            sport="$value"
                            find=lport
                            ;;
                    esac
                    ;;
                sport)
                    sport="$value"
                    find=dport
                    ;;
                dport)
                    dport="$value"
                    find=sport
            esac
            ;;
        sport)
            case "$key" in
                sport)
                    sport="$value"
                    [[ -n "$dport" ]] && action=register
                    ;;
                 *) echo Syntax error. Expected key: sport.>&2 ; exit 1;
            esac
            ;;
        dport)
            case "$key" in
                dport)
                    dport="$value"
                    [[ -n "$sport" ]] && action=register
                    ;;
                 *) echo Syntax error. Expected key: dport.>&2 ; exit 1;
            esac
            ;;
        lport)
            case "$key" in
                lport)
                    case "$what" in
                        lpf)
                            sport="$value"
                            [[ -n "$dport" ]] && action=register
                            ;;
                        rpf)
                            dport="$value"
                            [[ -n "$sport" ]] && action=register
                            ;;
                    esac
                    ;;
                 *) echo Syntax error. Expected key: lport.>&2 ; exit 1;
            esac
            ;;
        rport)
            case "$key" in
                rport)
                    case "$what" in
                        lpf)
                            dport="$value"
                            [[ -n "$sport" ]] && action=register
                            ;;
                        rpf)
                            sport="$value"
                            [[ -n "$dport" ]] && action=register
                            ;;
                    esac
                    ;;
                 *) echo Syntax error. Expected key: rport.>&2 ; exit 1;
            esac
            ;;
        *)
            case "$value" in
                lpf)
                    string="from,${key}.lpf,localhost.${string}"
                    find=host
                    ;;
                rpf)
                    string="from,${key}.rpf,localhost.${string}"
                    find=host
            esac
            case "$key" in
                lpf)
                    what=lpf
                    host="$value"
                    find=port
                    ;;
                rpf)
                    what=rpf
                    host="$value"
                    find=port
                    ;;
                rport|lport)
                    find=port
                    string="${key},${value}.${string}"
                    ;;
                from)
                    host="$value"
                    if [ -n "$host_final" ];then
                        if [[ ! "$host" == "$host_final" ]];then
                            echo Syntax error. Key '`'from'`' can not more than one host.>&2 ; exit 1;
                        fi
                    fi
                    host_final="$value"
                    find=
                    ;;
                ip)
                    [ -n "$value" ] && host2ip+=("$value")
                    ;;
                timeout)
                    [ -n "$value" ] && options+=("ConnectTimeout=$value")
                    ;;
                keepalive)
                    options+=("ServerAliveInterval=10" "ServerAliveCountMax=2")
                    ;;
                daemon)
                    flag+=("f" "N")
                    ;;
                o)
                    [ -n "$value" ] && options+=("$value")
                    ;;
                f)
                    [ -n "$value" ] && flag+=("$value")
                    ;;
                passwordless)
                    options+=("PreferredAuthentications=publickey" "PasswordAuthentication=no")
            esac
    esac
    case "$action" in
        register)
            register+=("${host},${what},${sport},${dport}")
            action=
            find=
            ;;
    esac
    if [ -z "$string" ];then
        case $find in
            lport) echo Syntax error. Expected key: lport.>&2 ; exit 1;;
            rport) echo Syntax error. Expected key: rport.>&2 ; exit 1;;
            sport) echo Syntax error. Expected key: sport.>&2 ; exit 1;;
            dport) echo Syntax error. Expected key: dport.>&2 ; exit 1;;
        esac
    fi
done
if [ -z "$host_final" ];then
    # Cari dari register, asal hanya satu host.
    for each in "${register[@]}";do
        host=$(cut -d, -f1 <<< "$each")
        [ -z "$host_final" ] && host_final="$host" || {
            if [ ! "$host_final" == "$host" ];then
                echo Syntax error. Key '`'from'`' required if tunneling host more than one.>&2 ; exit 1;
            fi
        }
    done
else
    # The key `from` is define, set all host to convert as IP Address.
    for each in "${register[@]}";do
        host=$(cut -d, -f1 <<< "$each")
        if [[ ! "$host" == 'localhost' ]];then
            host2ip+=("$host")
        fi
    done
fi
string="ssh"
if [ "${#flag}" -gt 0 ];then
    string+=" -"
    for each in "${flag[@]}";do
        string+="${each}"
    done
fi
for each in "${register[@]}";do
    host=$(cut -d, -f1 <<< "$each")
    what=$(cut -d, -f2 <<< "$each")
    sport=$(cut -d, -f3 <<< "$each")
    dport=$(cut -d, -f4 <<< "$each")
    sport=$(translatePort "$sport")
    dport=$(translatePort "$dport")
    if [ "$host" == "localhost" ];then
        if ArraySearch "$host_final" host2ip[@];then
            ip=$(getIP "$host_final")
            if [ -z "$ip" ];then
                echo IP Address for '"'$host_final'"' not found in ssh config '($HOME/.ssh/config)'. >&2 ;
                host="$host_final"
            else
                host="$ip"
            fi
        else
            host="127.0.0.1"
        fi
    elif ArraySearch "$host" host2ip[@];then
        ip=$(getIP "$host")
        if [ -z "$ip" ];then
            echo IP Address for '"'$host'"' not found in ssh config '($HOME/.ssh/config)'. >&2 ;
        else
            host="$ip"
        fi
    fi
    case "$what" in
        lpf)
            string+=" -L"
            ;;
        rpf)
            string+=" -R"
    esac
    string+=" ${sport}:${host}:${dport}"
done
for each in "${options[@]}";do
    string+=" -o ${each}"
done
string+=" ${host_final}"
echo "$string"

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
# )
# MULTIVALUE=(
# )
# FLAG_VALUE=(
# )
# CSV=(
# )
# EOF
# clear
