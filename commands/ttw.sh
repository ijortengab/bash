# !/bin/bash

# Trim Trailing Whitespace Command
#
#   ```
#   ttw git
#   ```
#
#   Command above is shortcut for:
#
#   ```
#   git ls-files | while IFS= read -r path; do sed -i -e 's/[ ]*$//' -e :a -e '/^\n*$/{$d;N;ba' -e '}' "$path" ; done;
#   ```
#
#   ```
#   ttw php
#   ```
#
#   Command above is shortcut for:
#
#   ```
#   git ls-files | while IFS= read -r path; do sed -i -e 's/[ ]*$//' -e :a -e '/^\n*$/{$d;N;ba' -e '}' "$path" ; done;
#   ```
#
# Credit:
#  - https://stackoverflow.com/questions/4438306/how-to-remove-trailing-whitespaces-with-sed
#  - https://gist.github.com/zbeekman/c3f2ef40ea176ba550fe

case "$1" in
    git)
        git ls-files | while IFS= read -r path; do echo "$path"; sed -i -e 's/[ ]*$//' -e :a -e '/^\n*$/{$d;N;ba' -e '}' "$path" ; done;
    ;;
    php)
        find "$PWD" -type d \( -name ".*" -o -name "vendor" \) -prune -false -o -type f -name "*.php" | while IFS= read -r path; do echo "$path"; sed -i -e 's/[ ]*$//' -e :a -e '/^\n*$/{$d;N;ba' -e '}' "$path" ; done;
    ;;
    *)
        echo "Usage: ttw [git|php]";
    ;;
esac
