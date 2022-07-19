#!/bin/bash

#
# @filename: var-dump.function.sh
# @version: 1.0
# @release-date: 20210105
# @author: IjorTengab <ijortengab@gmail.com>
#
# Mencetak variable untuk keperluan debug (pengecekan dan fixasi).
# Pencetakan disertai syntax highlighting. Dapat mencetak array maupun non
# array (string/number).
#
# Globals:
#   None
#
# Arguments:
#   $@: Semua variable yang masuk akan dianggap sebagai parameter atau value
#        untuk kemudian dicetak.
#
# Returns:
#   None
#
# Output:
#   Mencetak parameter dan value dari variable ke stdout.
#
# Argument yang masuk akan dianggap parameter. Contoh:
#
# ```
# tujuan=Jakarta
# rute=("Jakarta" "Surabaya")
# varDump tujuan rute
# ```
#
# Hasil yang diperoleh (stdout) adalah:
#
# ```
# $tujuan = "Jakarta"
# $rute = ( "Jakarta" "Surabaya" )
# ```
#
# Untuk argument berupa variable numeric (positional parameter), maka sebaiknya
# menggunakan format label namun hanya berlaku untuk non array. Contoh:
#
# ```
# rute=("Jakarta" "Semarang" "Yogyakarta" "Surabaya")
# set -- ${rute[@]}
# varDump '<$1>'"$1" '<$2_before>'"$2"
# echo Proses disini
# varDump '<$2_after>'"$2"
# ```
#
# Hasil yang diperoleh (stdout) adalah:
#
# ```
# $1 = "Jakarta"
# $2_before = "Semarang"
# Proses disini
# $2_after = "Semarang"
# ```
#
# Argument yang tidak valid sebagai parameter, maka akan dicetak dengan
# mengganggap sebagai value.
VarDump() {
    local i
    local globalVarName globalVarValue label value
    local normal red yellow cyan magenta
    normal="$(tput sgr0)"
    red="$(tput setaf 1)"
    yellow="$(tput setaf 3)"
    cyan="$(tput setaf 6)"
    magenta="$(tput setaf 5)"
    while [[ $# -gt 0 ]]; do
        # Jika argument adalah value kosong.
        if [[ $1 == '' ]];then
            printf "${yellow}\"\"${normal} \n"
            shift
            continue
        fi
        # Jika argument memiliki format khusus untuk labelling.
        # Yakni <...>....
        # Contoh:
        # ```
        # kondisi=mentah
        # varDump '<$tempe>'"$kondisi"
        # ```
        # Hasilnya adalah `$tempe = mentah`
        if [[ $1 =~ ^\<.*\> ]];then
            label=$(echo $1 | cut -d'>' -f1 | cut -c2-)
            value=$(echo $1 | cut -d'>' -f2 )
            value=${value//\\/\\\\} # Backslash to Double Backslash
            printf "${cyan}$label${normal}${red} = ${normal}"
            printf "\"${yellow}$value${normal}\" \n"
            shift
            continue
        fi
        # Jika argument tidak valid sebagai parameter.
        if [[ $1 =~ [^0-9a-zA-Z_] || $1 =~ ^[0-9] ]];then
            value=${1//\\/\\\\} # Backslash to Double Backslash
            printf "${magenta}$value${normal}\n"
            shift
            continue
        fi
        # Check variable jika merupakan associative array.
        eval check=\$\(declare -p $1 2\>\/dev\/null\)
        if [[ "$check" =~ "declare -A" ]]; then
            eval globalVarKey=\(\"\${!$1[@]}\"\)
            eval globalVarValue=\(\"\${$1[@]}\"\)
            printf "${cyan}\$$1${normal}${red} = ( ${normal}"
            for i in "${!globalVarKey[@]}"
            do
                value="${globalVarValue[$i]}"
                value=${value//\\/\\\\} # Backslash to Double Backslash
                printf "\"${cyan}${globalVarKey[$i]}${normal}\" ${red}=>${normal} \"${yellow}${value}${normal}\" "
            done
            printf "${red})${normal}\n"
            shift
            continue
        fi
        # Check jika variable tidak pernah diset.
        eval isset=\$\(if \[ -z \$\{$1+x\} \]\; then echo 0\; else echo 1\; fi\)
        if [ $isset == 0 ];then
            value=${1//\\/\\\\} # Backslash to Double Backslash
            printf "${yellow}${value}${normal}\n"
            shift
            continue
        fi
        # Check variable jika merupakan array.
        eval check=\$\(declare -p $1\)
        if [[ "$check" =~ "declare -a" ]]; then
            eval globalVarValue=\(\"\${$1[@]}\"\)
            printf "${cyan}\$$1${normal}${red} = ( ${normal}"
            for (( i=0; i < ${#globalVarValue[@]} ; i++ )); do
                value="${globalVarValue[$i]}"
                value=${value//\\/\\\\} # Backslash to Double Backslash
                printf "\"${yellow}${value}${normal}\" "
            done
            printf "${red})${normal}\n"
            shift
            continue
        fi
        # Variable selain itu.
        globalVarName=$1
        globalVarValue=${!globalVarName}
        value=${globalVarValue//\\/\\\\}
        printf "${cyan}\$$globalVarName${normal}${red} = ${normal}"
        printf "\"${yellow}${value}${normal}\" \n"
        shift
    done
}
