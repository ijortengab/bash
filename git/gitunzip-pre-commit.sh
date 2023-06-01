#!/bin/bash

command -v unzip >/dev/null 2>&1 || { echo -e >&2 "\nThis repository is configured for Git Unzip but 'unzip' was not found on your path. If you no longer wish to use Git Unzip, remove this hook by deleting '.git/hooks/pre-commit'.\n"; exit 2; }

prettyPrintXML() {
    local isTidyExists tidyWarningPrinted isXML
    command -v tidy >/dev/null 2>&1 && isTidyExists=yes
    if [ -d "$1" ];then
        find "$1" -type f | while IFS= read -r file; do
            isXML=
            if [[ "$file" =~ .xml$ ]];then
                isXML=yes
            elif [[ $(file -b --mime-type "$file") == 'text/xml' ]];then
                isXML=yes
            fi
            if [[ -n $isXML ]];then
                if [[ -n $isTidyExists ]];then
                    tidy -q -xml -i -m "$file"
                elif [[ -z $tidyWarningPrinted ]];then
                    tidyWarningPrinted=done
                    echo -e "\e[93m""'tidy' was not found on your path, it's recomended for versioning XML files.""\e[39m"
                fi
            fi
        done
    fi
}

dotgitunzip="$(git rev-parse --show-toplevel)/.gitunzip"

if [ -f "$dotgitunzip" ];then
    git diff --cached --name-status | grep -E '^(A|M)' | cut -f2 -d$'\t' | while IFS= read -r file; do
        if grep -q -f <(sed 's/\([.|]\)/\\\1/g; s/\?/./g ; s/\*/.*/g; s/\(.*\)\([^\]\)$/\\\1\2\$/g' "$dotgitunzip") <<< "$file";then
            echo "Unzip: ${file}" >&2
            unzip -o -qq "${file}" -d "${file}.d" >&2
            prettyPrintXML "${file}.d"
            git add "${file}.d/"
        fi
    done
    git diff --cached --name-status | grep -E '^(D|R)' | cut -f2 -d$'\t' | while IFS= read -r file; do
        if grep -q -f <(sed 's/\([.|]\)/\\\1/g; s/\?/./g ; s/\*/.*/g; s/\(.*\)\([^\]\)$/\\\1\2\$/g' "$dotgitunzip") <<< "$file";then
            echo "Remove extracted directory: ${file}" >&2
            rm -rf "${file}.d"
            git add "${file}.d/"
        fi
    done
    git diff --cached --name-status | grep '^R[[:digit:]]' | cut -f3 -d$'\t' | while IFS= read -r file; do
        if grep -q -f <(sed 's/\([.|]\)/\\\1/g; s/\?/./g ; s/\*/.*/g; s/\(.*\)\([^\]\)$/\\\1\2\$/g' "$dotgitunzip") <<< "$file";then
            echo "Unzip: ${file}" >&2
            unzip -o -qq "${file}" -d "${file}.d" >&2
            prettyPrintXML "${file}.d"
            git add "${file}.d/"
        fi
    done
fi
