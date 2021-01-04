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

Use global variable `VALUE`, if you wamts to collect any string. Thiw options
is required value. Example:

```
VALUE=(
    --directory|-D
    --web-root
)
```

Use global variable `$FLAG_VALUE`, if you wamts to collect any string. Thiw
options is not required. If value omitted, default is boolean `1`. Example:

```
FLAG_VALUE=(
    --with-ssl
)
```

Later, you can using options like this:

```
yourscript.sh --with-ssl
```

or,

```
yourscript.sh --with-ssl=openssl
```

Use global variable `MULTIVALUE`, if you wants to collect array of value. Thiw
options is required value. Example:

```
MULTIVALUE=(
    --execute|-e
)
```

Use global variable `INCREMENT`, if you wants to set integer that increasing if
the optios is set more than one. Example:

```
INCREMENT=(
    --verbose|-v
)
```

Five global variable above will be crete variable with parameter same as
parameter of options which dash will replace by underscore and trim the dash.
Long options with two dash will be first candidate of parameter name, then short
option for the next.  Example:

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
  if type if `flag`.

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
    Code tidak akan terdapat definisi original arguments.
--no-rebuild-arguments
    Code tidak akan melakukan reposisi arguments (set -- ${array[@]})
    Gunakan jika script memang tidak terdapat operand (arguments non option)
    atau keseluruhan options adalah standalone.
    Option ini tidak berlaku jika terjadi looping kedua dengan getopts, yakni
    terdapat satu shortoption single character type yg butuh value (value,
    flag_value, multivalue) atau terdapat minimal dua shortoption single
    character yang tidak butuh value (flag, flag_value, increment).
    Option ini juga tidak berlaku jika berlaku option salah satu dibawah ini:
    --with-end-options-double-dash atau --with-end-options-first-operand
--output-file <n>
    Code yang dibuat tidak akan dikirim ke stdout tetapi disimpan sebagai
    file.
--path-shell <n>
    String path shell diawal baris. Default: `/bin/bash`
--sort <n>
    Urutan option saat looping menggunakan while. Pisahkan dengan comma
    diantara pilihan berikut: alphabet,type,.
    Contoh value adalah sbb:
    - alphabet,type
    - type,alphabet
    - type,priority,alphabet
    - type
    - priority,type,alphabet (default)
    Untuk sort berdasrkan `type` terdapat options tambahan untuk sorting lagi.
--sort-type-flag <n>
    Prioritas sort untuk type flag.
    <n> adalah integer 1 sampai 9. Default 1.
--sort-type-flag-value <n>
    Prioritas sort untuk type flag-value.
    <n> adalah integer 1 sampai 9. Default 3.
--sort-type-increment <n>
    Prioritas sort untuk type increment.
    <n> adalah integer 1 sampai 9. Default 4.
--sort-type-multivalue <n>
    Prioritas sort untuk type multivalue.
    <n> adalah integer 1 sampai 9. Default 5.
--sort-type-value <n>
    Prioritas sort untuk type value.
    <n> adalah integer 1 sampai 9. Default 2.
--with-end-options-double-dash
    Code yang dibuat akan menjadikan double dash sebagai end options.
--without-end-options-double-dash
    Code yang dibuat tidak akan menjadikan double dash sebagai end options.
--with-end-options-first-operand
    Code yang dibuat akan menjadikan first operand (argument non options)
    sebagai end options.
--without-end-options-first-operand
    Code yang dibuat tidak akan menjadikan first operand
    (argument non options) sebagai end options.
