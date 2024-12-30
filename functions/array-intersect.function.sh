# Computes the difference of arrays.
#
# Globals:
#   Modified: _return
#
# Arguments:
#   1 = Parameter of the array to compare from.
#   2 = Parameter of the array to compare against.
#
# Returns:
#   None
#
# Example:
#   ```
#   my=("cherry" "manggo" "blackberry" "manggo" "blackberry")
#   yours=("cherry" "blackberry")
#   ArrayIntersect my[@] yours[@]
#   # Get result in variable `$_return`.
#   # _return=("cherry" "blackberry" "blackberry")
#   ```
ArrayIntersect() {
    local e
    local source=("${!1}")
    local reference=("${!2}")
    _return=()
    # inArray is alternative of ArraySearch.
    inArray () {
        local e match="$1"
        shift
        for e; do [[ "$e" == "$match" ]] && return 0; done
        return 1
    }
    if [[ "${#reference[@]}" -gt 0 ]];then
        for e in "${source[@]}";do
            if inArray "$e" "${reference[@]}";then
                _return+=("$e")
            fi
        done
    else
        _return=("${source[@]}")
    fi
}
