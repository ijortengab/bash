# Find element in Array. Searches the array for a given value and returns the
# first corresponding key if successful.
#
# Globals:
#   Modified: _return
#
# Arguments:
#   1 = The searched value.
#   2 = Parameter of the array.
#
# Returns:
#   0 if value found in the array.
#   1 otherwise.
#
# Example:
#   ```
#   my=("cherry" "manggo" "blackberry" "manggo" "blackberry")
#   ArraySearch "manggo" my[@]
#   if ArraySearch "blackberry" my[@];then
#       echo 'FOUND'
#   else
#       echo 'NOT FOUND'
#   fi
#   # Get result in variable `$_return`.
#   # _return=2
#   ```
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
