# Shift an element off the beginning of array
#
# Globals:
#   Modified: _return
#
# Arguments:
#   1 = Parameter of the array.
#
# Returns:
#   None
#
# Example:
#   ```
#   my=("cherry" "manggo" "blackberry" "manggo" "blackberry")
#   ArrayShift my[@]
#   # Get result in variable `$_return`.
#   # _return=("manggo" "blackberry" "manggo" "blackberry")
#   ```
ArrayShift() {
    local index
    local source=("${!1}")
    _return=()
    for (( index=1; index < ${#source[@]} ; index++ )); do
        _return+=("${source[$index]}")
    done
}
