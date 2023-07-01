#!/bin/bash

# Awalnya seperti ini:
# __FILE__=$(realpath "$0")
# __DIR__=$(dirname "$__FILE__")
# Command `realpath` malah memberikan path yang sebenarnya, sehingga
# symlink direktori juga kebawa berubah.
# Untuk berikutnya, kita gunakan command ini `resolve-relative-path.sh`.
# Sehingga koreksi menjadi:
# __FILE__=$(resolve-relative-path.sh "$0")
# __DIR__=$(dirname "$__FILE__")
#
# How to test.
# Create real path and file.
# ```
# mkdir -p ~/github.com/ijortengab/bash/commands
# rm ~/github.com/ijortengab/bash/commands/script.sh
# touch ~/github.com/ijortengab/bash/commands/script.sh
# chmod a+x ~/github.com/ijortengab/bash/commands/script.sh
# echo 'resolve_relative_path() ('
# echo '    if [ -d "$1" ]; then'
# echo '        cd "$1" || return 1'
# echo '        pwd'
# echo '    elif [ -e "$1" ]; then'
# echo '        if [ ! "${1%/*}" = "$1" ]; then'
# echo '            cd "${1%/*}" || return 1'
# echo '        fi'
# echo '        echo "$(pwd)/${1##*/}"'
# echo '    else'
# echo '        return 1 '
# echo '    fi'
# echo ')'
# echo '__FILE__=$(resolve_relative_path "$0")' >> ~/github.com/ijortengab/bash/commands/script.sh
# echo '__DIR__=$(dirname "$__FILE__")' >> ~/github.com/ijortengab/bash/commands/script.sh
# echo 'echo __FILE__=$__FILE__' >> ~/github.com/ijortengab/bash/commands/script.sh
# echo 'echo __DIR__=$__DIR__' >> ~/github.com/ijortengab/bash/commands/script.sh
# ```
# Create symbolic link of directory.
# ```
# mkdir -p ~/bin
# ln -s ~/bin -T ~/binary
# ```
# Create symbolic link of file anywhere.
# ```
# ln -s ~/github.com/ijortengab/bash/commands/script.sh /usr/local/bin
# ln -s /usr/local/bin/script.sh ~/binary
# ```
# Test this function. The result expected.
# bash ~/github.com/ijortengab/bash/commands/script.sh
# bash /usr/local/bin/script.sh
# script.sh
# cd ~/binary
# bash script.sh
# ./script.sh

# Credit: https://www.baeldung.com/linux/bash-expand-relative-path
resolve_relative_path() (
    # If the path is a directory, we just need to 'cd' into it and print the new path.
    if [ -d "$1" ]; then
        cd "$1" || return 1
        pwd
    # If the path points to anything else, like a file or FIFO
    elif [ -e "$1" ]; then
        # Strip '/file' from '/dir/file'
        # We only change the directory if the name doesn't match for the cases where
        # we were passed something like 'file' without './'
        if [ ! "${1%/*}" = "$1" ]; then
            cd "${1%/*}" || return 1
        fi
        # Strip all leading slashes upto the filename
        echo "$(pwd)/${1##*/}"
    else
        return 1 # Failure, neither file nor directory exists.
    fi
)

resolve_relative_path "$1"
