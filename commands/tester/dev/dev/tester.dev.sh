#!/bin/bash

source $(dirname $0)/tester.parse_options.sh
source $(dirname $0)/../../../../functions/var-dump/dev/var-dump.function.sh
source $(dirname $0)/tester.debug.sh

source $(dirname $0)/tester.functions.sh

if [[ ! $1 == "" ]];then
    eval _output=\$\("$1"\)
    _result=$?
    yellowL; _echo "---"; white; _break;
    yellowL; _echo "$1"; white; _break;
    yellowL; _echo "---"; white; _break;
    if [[ $_result == 0 ]];then
        greenL; _echo "Success."; white; _echo " Command return: $_result"; _break;
    else
        redL; _echo "Error."; white; _echo " Command return: $_result"; _break;
    fi
    # Check Output.
    if [[ ! $output == "" ]];then
        if [[ "$output" == "$_output" ]];then
            greenL; _echo "Success."; white ; _echo " Output match:"; _break;
            magentaL; _echo "$_output"; white; _break
        else
            redL; _echo "Error."; white ; _echo " Output not match:"; _break;
            magentaL; _echo "$_output"; white; _break
        fi
    fi
    # Check File Exists.
    if [[ ${#file_exists[@]} -gt 0 ]];then
        for e in "${file_exists[@]}"; do
            if [ -f "$e" ];then
                   greenL; _echo "Success."; white ; _echo " File exists:"; _echo " $e"; _break
            else
                    redL; _echo "Error."; white ; _echo " File not exists:"; _echo " $e"; _break
            fi
        done
    fi
    # Check File Is Not Exists.
    if [[ ${#file_not_exists[@]} -gt 0 ]];then
        for e in "${file_not_exists[@]}"; do
            if [ ! -f "$e" ];then
                   greenL; _echo "Success."; white ; _echo " File not exists:"; _echo " $e"; _break
            else
                    redL; _echo "Error."; white ; _echo " File exists:"; _echo " $e"; _break
            fi
        done
    fi
    _break
fi
