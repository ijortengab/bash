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
    _return=("${!2}")
    for index in "${!_return[@]}"; do
       if [[ "${_return[$index]}" == "${match}" ]]; then
            _return=("${_return[@]:0:$index}" "${_return[@]:$(($index + 1))}")
           break
       fi
    done
}
