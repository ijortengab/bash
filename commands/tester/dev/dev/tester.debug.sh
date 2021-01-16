#!/bin/bash

normal="$(tput sgr0)"
red="$(tput setaf 1)"
yellow="$(tput setaf 3)"
cyan="$(tput setaf 6)"
magenta="$(tput setaf 5)"

echo
echo ${yellow}'# Options'${normal}
echo
echo -n ${red}-fe, --file-exists${normal}" ..... "${cyan}\$file_exists${normal}" .... = ""( "
for _e_ in "${file_exists[@]}"; do if [[ $_e_ =~ " " ]];then echo -n \"${magenta}"$_e_"${normal}\"" ";else echo -n ${magenta}"$_e_"${normal}" ";fi;done
echo ")"
echo -n ${red}-fne, --file-not-exists${normal}"  "${cyan}\$file_not_exists${normal}"  = ""( "
for _e_ in "${file_not_exists[@]}"; do if [[ $_e_ =~ " " ]];then echo -n \"${magenta}"$_e_"${normal}\"" ";else echo -n ${magenta}"$_e_"${normal}" ";fi;done
echo ")"
echo    ${red}-o, --output${normal}" ........... "${cyan}\$output${normal}" ......... = "${magenta}$output${normal}

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
