# Documentation

This function save our time, we don't need to write "parsing arguments" code
again and focus about develop your entire script.

## Learn by practice

This function read five global variables:

```
FLAG=()
VALUE=()
FLAG_VALUE=()
MULTIVALUE=()
INCREMENT=()
```

Set your options as array member inside global variables above.

Each array member must have value the parameter of options such as long option
prefix with double dash (`--long-options`), short option `-s`, short options
prefix more than one character `-maxdepth`, or combine double dash and single
dash separete with pipe (`--verbose|-v`).

Use global variable `FLAG`, if you wants to collect boolean `1`. But if you
wants to set value boolean `0`, you have to using global variable `CSV` instead
(will explain later). Example:

```
FLAG=(
    --version|-V
    --help|-h
)
```

Use global variable `VALUE`, if you wants to collect any string. This options
is required value. Example:

```
VALUE=(
    --directory|-D
    --web-root
)
```

Use global variable `FLAG_VALUE`, if you wants to collect any string. This
options is not required. If value omitted, default is boolean `1`. Example:

```
FLAG_VALUE=(
    --with-ssl
)
```

Later, you can use options like this:

```
script.sh --with-ssl
```

or this:

```
script.sh --with-ssl=openssl
```

Use global variable `MULTIVALUE`, if you wants to collect array of value. This
options is required value. Example:

```
MULTIVALUE=(
    --execute|-e
)
```

Use global variable `INCREMENT`, if you wants to set integer that increasing if
the options is set more than one. Example:

```
INCREMENT=(
    --verbose|-v
)
```

Five global variable above will be made variable with the same parameter as the
option parameter which is replace all hyphen by the underscore and then trim
parameter from the underscore. Long options with two hyphens will be first
candidate as parameter name, then short option for the next one. Example:

- `--verbose|-v` will have parameter `verbose`.
- `--output|-o` will have parameter `output`.
- `-o` will have parameter `o`.
- `-V` will have parameter `V`.

Use global variable `CSV`, if you wants advanced configuration. Each value of
array, must a CSV (Comma Separated Value) which every field of CSV is combine of
`key` and `value` seperated with colon `:`. Example:

```
CSV=(
    long:--verbose,short:-v,parameter:verbose
)
```

The key field is:
- `long` for long option parameter name,
- `short` for short option parameter name,
- `parameter` for parameter variable name,
- `type`, type of how to collect value (`flag`, `value`, `flag_value`,
  `multivalue`, `increment`). If this key omitted, default is `flag`.
- `priority`, integer to sort which low number is high priority,
- `flag_option`, set `reverse` if you wants to set zero value `0` instead of `1`
  or set `true=n` if you wants to set `n` value instead of `1` which `n` value
  can changed to any string.
  Affected only for `flag` type.

Example:

If you wants to have acronym options like this:

```
--with-gd-library,
--without-gd-library.
```

You should using this global variable:

```
CSV=(
    'long:--with-gd-library,parameter:use_gd_library,'
    'long:--without-gd-library,parameter:use_gd_library,flag_option:reverse'
)
```

## Global Variables

All globlal variable that using by this function.

For simple options definitions: `FLAG`, `VALUE`, `FLAG_VALUE`, `MULTIVALUE`, `INCREMENT`

For complex options definitions: `CSV`

`INDENT` variable using for indentation definition. If omitted, we using four space.

`_NEW_ARGUMENTS` variable using for parameter name. Default value is `_new_arguments`.

`_N` variable using for parameter name. Default value is `_n`.

## Options.

```
--clean
    The generated code doesn't include any comment.
--compact
    The generated code will be minified.
--debug-file <n>
    Auto create debug file for testing and dump variable.
--no-error-invalid-options
    The generated code not include any output to STDERR if found any invalid options.
--no-error-require-arguments
    The generated code not include any output to STDERR if options that require arguments not have arguments.
--no-hash-bang
    The generated code not include hash bang (`#!/bin/bash`)
--no-original-arguments
    The generated code doesn't create a definition of original arguments.
--no-rebuild-arguments
    The generated code doesn't create a reposition arguments. (set -- ${array[@]})
    Use it if your script doesn't need operands (arguments non option).
    This option does not apply in case of a second loop with getopts, ie
    there is a single character type short option that needs value (value,
    flag_value, multivalue) or there are at least two single short options
    characters that don't need a value (flag, flag_value, increment).
    This option also does not apply if one of the following options applies:
     --with-end-options-double-dash or --with-end-options-first-operand
--output-file <n>
    The generated code is not sent to stdout but is saved as files.
--path-shell <n>
    Shell path string at the beginning of the line. Default: /bin/bash
--sort <n>
    Order of options when looping using while. Separate with commas among the
    following options: alphabet,type.
    Examples of values are as follows:
    - alphabet,type
    - type,alphabet
    - type,priority,alphabet
    - type
    - priority,type,alphabet (default)
    For sort by `type` there are additional options for sorting again.
--sort-type-flag <n>
    Sort priority for the flag type.
    <n> is an integer 1 through 9. Default 1.
--sort-type-flag-value <n>
    Prioritas sort untuk type flag-value.
    <n> is an integer 1 through 9. Default 3.
--sort-type-increment <n>
    Prioritas sort untuk type increment.
    <n> is an integer 1 through 9. Default 4.
--sort-type-multivalue <n>
    Prioritas sort untuk type multivalue.
    <n> is an integer 1 through 9. Default 5.
--sort-type-value <n>
    Prioritas sort untuk type value.
    <n> is an integer 1 through 9. Default 2.
--with-end-options-double-dash
    The generated code will make the double dash as end options.
--without-end-options-double-dash
    The generated code will not make the double dash as end options.
--with-end-options-first-operand
    The generated code will make the first operand (argument non options)
    as end options.
--without-end-options-first-operand
    The generated code will not make the first operand (argument non options)
    as end options.
```
