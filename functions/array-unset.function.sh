# Shift an element from the array by its key/index number.
#
# Globals:
#   Modified: _return
#
# Arguments:
#   1 = key off element value that will be remove
#   2 = Parameter of the array
#
# Returns:
#   None
#
# Example:
#   ```
#   my=("cherry" "manggo" "blackberry" "manggo" "blackberry")
#   ArrayUnset 1 my[@]
#   # Get result in variable `$_return`.
#   # _return=("cherry" "blackberry" "manggo" "blackberry")
#   ```
ArrayUnset() {
    local index="$1"
    local source=("${!2}")
    _return=("${source[@]:0:$index}" "${source[@]:$(($index + 1))}")
}
