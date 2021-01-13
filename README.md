# Bash Script Collection

## Functions

List all functions.

```sh
find functions/ -maxdepth 3 -type f -name *.sh | sort
find functions/ -maxdepth 3 -type f -name *.sh | sort | while IFS="" read -r p; do cat "$p"; done
```

```txt
functions/array-diff/dev/array-diff.function.sh
functions/array-remove-all/dev/array-remove-all.function.sh
functions/array-remove/dev/array-remove.function.sh
functions/array-search/dev/array-search.function.sh
functions/array-shift/dev/array-shift.function.sh
functions/array-unique/dev/array-unique.function.sh
functions/array-unset/dev/array-unset.function.sh
functions/code-generator-parse-options/dev/code-generator-parse-options.function.sh
functions/var-dump/dev/var-dump.function.sh
```

`ArrayDiff`

> Computes the difference of arrays

`ArrayRemoveAll`

> Shift all element from the array

`ArrayRemove`

> Shift an element from the array, only first match.

`ArraySearch`

> Find element in Array. Searches the array for a given value and returns the
> first corresponding key if successful.

`ArrayShift`

> Shift an element off the beginning of array.

`ArrayUnique`

> Removes duplicate values from an array.

`ArrayUnset`

> Shift an element from the array by its key/index number

`CodeGeneratorParseOptions()`

> Code Generator for Parsing Options in Command Line Arguments.

`VarDump()`

> Variable Dump for Debugging.
