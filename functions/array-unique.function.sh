# Removes duplicate values from an array.
#
# Globals:
#   Modified: _return
#
# Arguments:
#   1 = Parameter of the input array.
#
# Returns:
#   None
#
# Example:
#   ```
#   my=("cherry" "manggo" "blackberry" "manggo" "blackberry")
#   ArrayUnique my[@]
#   # Get result in variable `$_return`.
#   # _return=("cherry" "manggo" "blackberry")
#   ```
ArrayUnique() {
    local e source=("${!1}")
    # inArray is alternative of ArraySearch.
    inArray () {
        local e match="$1"
        shift
        for e; do [[ "$e" == "$match" ]] && return 0; done
        return 1
    }
    _return=()
    for e in "${source[@]}";do
        if ! inArray "$e" "${_return[@]}";then
            _return+=("$e")
        fi
    done
}
