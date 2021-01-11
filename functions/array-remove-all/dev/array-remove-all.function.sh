# Shift all element from the array
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
#   ArrayRemoveAll "manggo" my[@]
#   # Get result in variable `$_return`.
#   # _return=("cherry" "blackberry" "blackberry")
#   ```
ArrayRemoveAll() {
    local index match="$1"
    local source=("${!2}")
    _return=()
    for index in "${!source[@]}"; do
       if [[ ! "${source[$index]}" == "${match}" ]]; then
           _return+=("${source[$index]}")
       fi
    done
}
