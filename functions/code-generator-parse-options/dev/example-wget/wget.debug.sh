#!/bin/bash

normal="$(tput sgr0)"
red="$(tput setaf 1)"
yellow="$(tput setaf 3)"
cyan="$(tput setaf 6)"
magenta="$(tput setaf 5)"

echo
echo ${yellow}'# Options'${normal}
echo
echo ${cyan}\$help${normal}" ............... = "${magenta}$help${normal}${red}" # -h, --help"${normal}
echo ${cyan}\$version${normal}" ............ = "${magenta}$version${normal}${red}" # -V, --version"${normal}
echo ${cyan}\$append_output${normal}" ...... = "${magenta}$append_output${normal}${red}" # -a, --append-output"${normal}
echo ${cyan}\$background${normal}" ......... = "${magenta}$background${normal}${red}" # -b, --background"${normal}
echo ${cyan}\$debug${normal}" .............. = "${magenta}$debug${normal}${red}" # -d, --debug"${normal}
# multivalue
echo -n \
     ${cyan}\$execute${normal}" ............ = "'( '
for e in "${execute[@]}"
do
    if [[ $e =~ " " ]];then
        echo -n '"'${magenta}"$e"${normal}'"'' '
    else
        echo -n ${magenta}"$e"${normal}' '
    fi
done
echo ')'${normal}${red}" # # -e, --execute"${normal}
echo ${cyan}\$no_host_directories${normal}"  = "${magenta}$no_host_directories${normal}${red}" # -nH, --no-host-directories"${normal}
echo ${cyan}\$output_document${normal}" .... = "${magenta}$output_document${normal}${red}" # -O, --output-document"${normal}
echo ${cyan}\$output_file${normal}" ........ = "${magenta}$output_file${normal}${red}" # -o, --output-file"${normal}
echo ${cyan}\$quiet${normal}" .............. = "${magenta}$quiet${normal}${red}" # -q, --quiet"${normal}

echo
echo ${yellow}'# New Arguments (Operand)'${normal}
echo
echo ${cyan}\$1${normal} = ${magenta}$1${normal}
echo ${cyan}\$2${normal} = ${magenta}$2${normal}
echo ${cyan}\$3${normal} = ${magenta}$3${normal}
echo ${cyan}\$4${normal} = ${magenta}$4${normal}
echo ${cyan}\$5${normal} = ${magenta}$5${normal}
echo ${cyan}\$6${normal} = ${magenta}$6${normal}
echo ${cyan}\$7${normal} = ${magenta}$7${normal}
echo ${cyan}\$8${normal} = ${magenta}$8${normal}
echo ${cyan}\$9${normal} = ${magenta}$9${normal}
