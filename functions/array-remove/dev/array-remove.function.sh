# Shift an element from the array, only first match.
#
# Globals:
#   Modified: _return
#
# Arguments:
#   1 = element value that will be remove.
#   2 = Parameter of the array.
#
# Returns:
#   None
#
# Example:
#   ```
#   my=("cherry" "manggo" "blackberry" "manggo" "blackberry")
#   ArrayRemove "manggo" my[@]
#   # Get result in variable `$_return`.
#   # _return=("cherry" "blackberry" "manggo" "blackberry")
#   ```
ArrayRemove() {
    local index match="$1"
    local source=("${!2}")
    for index in "${!source[@]}"; do
       if [[ "${source[$index]}" == "${match}" ]]; then
           break
       fi
    done
    _return=("${source[@]:0:$index}" "${source[@]:$(($index + 1))}")
}
