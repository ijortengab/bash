#!/bin/bash

normal="$(tput sgr0)"
red="$(tput setaf 1)"
yellow="$(tput setaf 3)"
cyan="$(tput setaf 6)"
magenta="$(tput setaf 5)"

echo
echo ${yellow}'# Options'${normal}
echo
echo    ${red}-h, --help${normal}" ................ "${cyan}\$help${normal}" ............... = "${magenta}$help${normal}
echo    ${red}-V, --version${normal}" ............. "${cyan}\$version${normal}" ............ = "${magenta}$version${normal}
echo    ${red}-a, --append-output${normal}" ....... "${cyan}\$append_output${normal}" ...... = "${magenta}$append_output${normal}
echo    ${red}-b, --background${normal}" .......... "${cyan}\$background${normal}" ......... = "${magenta}$background${normal}
echo    ${red}-d, --debug${normal}" ............... "${cyan}\$debug${normal}" .............. = "${magenta}$debug${normal}
echo -n ${red}-e, --execute${normal}" ............. "${cyan}\$execute${normal}" ............ = ""( "
for _e_ in "${execute[@]}"; do if [[ $_e_ =~ " " ]];then echo -n \"${magenta}"$_e_"${normal}\"" ";else echo -n ${magenta}"$_e_"${normal}" ";fi;done
echo ")"
echo    ${red}-nH, --no-host-directories${normal}"  "${cyan}\$no_host_directories${normal}"  = "${magenta}$no_host_directories${normal}
echo    ${red}-O, --output-document${normal}" ..... "${cyan}\$output_document${normal}" .... = "${magenta}$output_document${normal}
echo    ${red}-o, --output-file${normal}" ......... "${cyan}\$output_file${normal}" ........ = "${magenta}$output_file${normal}
echo    ${red}-q, --quiet${normal}" ............... "${cyan}\$quiet${normal}" .............. = "${magenta}$quiet${normal}

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
