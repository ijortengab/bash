#!/bin/bash

normal="$(tput sgr0)"
red="$(tput setaf 1)"
yellow="$(tput setaf 3)"
cyan="$(tput setaf 6)"
magenta="$(tput setaf 5)"

echo
echo ${yellow}'# Options'${normal}
echo
echo    ${red}-4${normal}"  "${cyan}\$_4${normal}"  = "${magenta}$_4${normal}
echo    ${red}-l${normal}"  "${cyan}\$l${normal}"   = "${magenta}$l${normal}
echo -n ${red}-o${normal}"  "${cyan}\$o${normal}"   = ""( "
for _e_ in "${o[@]}"; do if [[ $_e_ =~ " " ]];then echo -n \"${magenta}"$_e_"${normal}\"" ";else echo -n ${magenta}"$_e_"${normal}" ";fi;done
echo ")"
echo    ${red}-v${normal}"  "${cyan}\$v${normal}"   = "${magenta}$v${normal}

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
