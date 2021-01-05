#!/bin/bash

#
# @filename: code-generator-parse-options.function.sh
# @version: 1.0
# @release-date: 20210103
# @author: IjorTengab <ijortengab@gmail.com>
#
# Membuat code untuk memparsing options dari argument yang biasanya digunakan
# pada awal-awal Bash Script.
#
# Globals:
#   Used:
#     FLAG, VALUE, FLAG_VALUE, MULTIVALUE, INCREMENT (For simple options
#     definition).
#     CSV (For complex options definition).
#     ORIGINAL_ARGUMENTS (Default value is `ORIGINAL_ARGUMENTS`)
#     INDENT (Default value is `    ` four spaces)
#     _NEW_ARGUMENTS (Default value is `_new_arguments`)
#     _N (Default value is `_n`)
#
# Arguments:
#   --clean
#     Code yang dibuat tidak akan terdapat comment informasi.
#   --compact
#     Code akan dibuat seringkas mungkin.
#   --debug-file <n>
#     Otomatis membuat file yang berisi print variable untuk keperluan debug.
#   --no-error-invalid-options
#     Code tidak akan menghasilkan output ke stderr jika ditemukan options yang
#     invalid.
#   --no-error-require-arguments
#     Code tidak akan menghasilkan output ke stderr jika ditemukan options yang
#     membutuhkan value.
#   --no-hash-bang
#     Code tidak akan terdapat hash bang diawal script.
#   --no-original-arguments
#     Code tidak akan terdapat definisi original arguments.
#   --no-rebuild-arguments
#     Code tidak akan melakukan reposisi arguments (set -- ${array[@]})
#     Gunakan jika script memang tidak terdapat operand (arguments non option)
#     atau keseluruhan options adalah standalone.
#     Option ini tidak berlaku jika terjadi looping kedua dengan getopts, yakni
#     terdapat satu shortoption single character type yg butuh value (value,
#     flag_value, multivalue) atau terdapat minimal dua shortoption single
#     character yang tidak butuh value (flag, flag_value, increment).
#     Option ini juga tidak berlaku jika berlaku option salah satu dibawah ini:
#     --with-end-options-double-dash atau --with-end-options-first-operand
#   --output-file <n>
#     Code yang dibuat tidak akan dikirim ke stdout tetapi disimpan sebagai
#     file.
#   --path-shell <n>
#     String path shell diawal baris. Default: `/bin/bash`
#   --sort <n>
#     Urutan option saat looping menggunakan while. Pisahkan dengan comma
#     diantara pilihan berikut: alphabet,type,.
#     Contoh value adalah sbb:
#     - alphabet,type
#     - type,alphabet
#     - type,priority,alphabet
#     - type
#     - priority,type,alphabet (default)
#     Untuk sort berdasrkan `type` terdapat options tambahan untuk sorting lagi.
#   --sort-type-flag <n>
#     Prioritas sort untuk type flag.
#     <n> adalah integer 1 sampai 9. Default 1.
#   --sort-type-flag-value <n>
#     Prioritas sort untuk type flag-value.
#     <n> adalah integer 1 sampai 9. Default 3.
#   --sort-type-increment <n>
#     Prioritas sort untuk type increment.
#     <n> adalah integer 1 sampai 9. Default 4.
#   --sort-type-multivalue <n>
#     Prioritas sort untuk type multivalue.
#     <n> adalah integer 1 sampai 9. Default 5.
#   --sort-type-value <n>
#     Prioritas sort untuk type value.
#     <n> adalah integer 1 sampai 9. Default 2.
#   --with-end-options-double-dash
#     Code yang dibuat akan menjadikan double dash sebagai end options.
#   --without-end-options-double-dash
#     Code yang dibuat tidak akan menjadikan double dash sebagai end options.
#   --with-end-options-first-operand
#     Code yang dibuat akan menjadikan first operand (argument non options)
#     sebagai end options.
#   --without-end-options-first-operand
#     Code yang dibuat tidak akan menjadikan first operand
#     (argument non options) sebagai end options.
#
# Returns:
#   1: Tidak bisa membuat code karena options yang didefinisikan tidak ada.
#
# Output:
#   Menulis generated code ke stdout, kecuali terdapat option `--output-file`.
#
# Tested in Ubuntu 20.04 bash version:
# GNU bash, version 4.4.20(1)-release (x86_64-pc-linux-gnu)

CodeGeneratorParseOptions() {

    # Global Variable
    local _global global=(
        FLAG VALUE FLAG_VALUE INCREMENT MULTIVALUE CSV
    )

    # Define.
    local original_arguments new_arguments n print_new_arguments ____

    # Temporary Variable used in looping.
    local E e i j

    # Temporary Variable.
    local _row _csv _comment
    local _sort _parameter _long_option _short_option _short_option_strlen _type
    local _alphabet _add _priority _sort_type _case _array _flag _line

    # Storage hasil mengolah $global.
    local csv_all=()
    local csv_short_option_strlen_1=() csv_short_option_strlen_1_flag_value=()

    local optstring
    local short_option_flag_value=
    local short_option_with_value=0
    local short_option_without_value=0
    local temporary_variable=()
    local longest=0 longest2=0

    local lines= lines_1=() lines_2=() lines_3=() lines_4=()
    local lines_5=() lines_6=() lines_7=() lines_8=() lines_9=()

    # Default value.
    local path_shell="/bin/bash"
    local sort='priority,alphabet'
    local sort_type_flag=1
    local sort_type_value=2
    local sort_type_flag_value=3
    local sort_type_increment=4
    local sort_type_multivalue=5
    local end_options_double_dash=1

    # Parse options
    while [[ $# -gt 0 ]]; do
        case "$1" in
            --clean) clean=1; shift ;;
            --compact) compact=1; shift ;;
            --debug-file=*) debug_file="${1#*=}"; shift ;;
            --debug-file) if [[ ! $2 == "" && ! $2 =~ ^-[^-] ]]; then debug_file="$2"; shift; fi; shift ;;
            --no-error-invalid-options) no_error_invalid_options=1; shift ;;
            --no-error-require-arguments) no_error_require_arguments=1; shift ;;
            --no-hash-bang) no_hash_bang=1; shift ;;
            --no-original-arguments) no_original_arguments=1; shift ;;
            --no-rebuild-arguments) no_rebuild_arguments=1; shift ;;
            --output-file=*) output_file="${1#*=}"; shift ;;
            --output-file) if [[ ! $2 == "" && ! $2 =~ ^-[^-] ]]; then output_file="$2"; shift; fi; shift ;;
            --path-shell=*) path_shell="${1#*=}"; shift ;;
            --path-shell) if [[ ! $2 == "" && ! $2 =~ ^-[^-] ]]; then path_shell="$2"; shift; fi; shift ;;
            --sort=*) sort="${1#*=}"; shift ;;
            --sort) if [[ ! $2 == "" && ! $2 =~ ^-[^-] ]]; then sort="$2"; shift; fi; shift ;;
            --sort-type-flag=*) sort_type_flag="${1#*=}"; shift ;;
            --sort-type-flag) if [[ ! $2 == "" && ! $2 =~ ^-[^-] ]]; then sort_type_flag="$2"; shift; fi; shift ;;
            --sort-type-flag-value=*) sort_type_flag_value="${1#*=}"; shift ;;
            --sort-type-flag-value) if [[ ! $2 == "" && ! $2 =~ ^-[^-] ]]; then sort_type_flag_value="$2"; shift; fi; shift ;;
            --sort-type-increment=*) sort_type_increment="${1#*=}"; shift ;;
            --sort-type-increment) if [[ ! $2 == "" && ! $2 =~ ^-[^-] ]]; then sort_type_increment="$2"; shift; fi; shift ;;
            --sort-type-multivalue=*) sort_type_multivalue="${1#*=}"; shift ;;
            --sort-type-multivalue) if [[ ! $2 == "" && ! $2 =~ ^-[^-] ]]; then sort_type_multivalue="$2"; shift; fi; shift ;;
            --sort-type-value=*) sort_type_value="${1#*=}"; shift ;;
            --sort-type-value) if [[ ! $2 == "" && ! $2 =~ ^-[^-] ]]; then sort_type_value="$2"; shift; fi; shift ;;
            --with-end-options-double-dash) end_options_double_dash=1; shift ;;
            --without-end-options-double-dash) end_options_double_dash=0; shift ;;
            --with-end-options-first-operand) end_options_first_operand=1; shift ;;
            --without-end-options-first-operand) end_options_first_operand=0; shift ;;
            *) shift ;;
        esac
    done

    # Mengecek apakah sebuah value sudah ada di dalam array.
    #
    # Globals:
    #   None
    #
    # Arguments:
    #   $1: Value yang akan dicek
    #   $2: Array sebagai referensi
    #
    # Returns:
    #   0: Value berada pada array
    #   1: Value tidak berada pada array
    #
    # Credit: https://stackoverflow.com/a/8574392/7074586
    #
    inArray() {
        local e match="$1"
        shift
        for e; do [[ "$e" == "$match" ]] && return 0; done
        return 1
    }

    # Membuat nama parameter dari options.
    #
    # Globals:
    #   None
    #
    # Arguments:
    #   $1: Option yang akan dibuat versi `parameter`-nya.
    #
    # Returns:
    #   None
    #
    # Output:
    #   Menulis string parameter ke stdout.
    #
    # Credit: https://stackoverflow.com/a/13210909
    #
    buildParameter() {
        local string
        string=${1//-/_}
        string=$(echo $string | sed -E "s/^_+//")
        if [[ $string =~ ^[0-9] ]];then
            string=_$string
        fi
        echo $string
    }

    # Mengecek validitas dari option name.
    #
    # Globals:
    #   None
    #
    # Arguments:
    #   $1: Value yang akan dicek.
    #
    # Returns:
    #   0: Valid
    #   1: Tidak valid
    #
    # Contoh valid: --preview --directory
    #
    validateLongOptionName() {
        wild=$(echo "$1" | grep '[^a-z\-]')
        if [[ ! $wild == '' ]];then
            echo 'Option name must not have character except a-z and dash (-).' >&2
            return 1
        fi
        if [[ ! "$1" =~ ^--[^-] ]];then
            echo 'Option name must beginning with two dash (--).' >&2
            return 1
        fi
        if [[ "$1" =~ -$ ]];then
            echo 'Option name must not ending with dash (-).' >&2
            return 1
        fi
        if [[ "$1" =~ [a-z]-[-]+[a-z] ]];then
            echo 'Option name must not have two dash or more inside character a-z.' >&2
            return 1
        fi
        return 0
    }

    # Mengecek validitas dari short option name.
    #
    # Globals:
    #   Modified: _short_option_strlen
    #
    # Arguments:
    #   $1: Value yang akan dicek.
    #
    # Returns:
    #   0: Valid
    #   1: Tidak valid
    #
    # Contoh valid: -a -V -4 -6
    #
    validateShortOptionName() {
        # Kasih underscore diawal agar tidak dianggap sebagai options
        # dari command echo.
        correct=$(echo _"$1" | grep -E '^_-[a-zA-Z0-9]+$')
        if [[ $correct == '' ]];then
            echo 'Short option name must beginning with single dash (-) followed by alphanumeric (0-9, a-z, A-Z).' >&2
            return 1
        fi
        _short_option_strlen=${#1}
        ((_short_option_strlen=$_short_option_strlen-1))
        return 0
    }

    # Populate global variable dari baris data CSV.
    #
    # Globals:
    #   Modified: _long_option, _short_option, _type, _priority, _parameter
    #             _flag
    #
    # Arguments:
    #   $1: Value yang akan parsing berdasarkan CSV.
    #
    # Returns:
    #   None
    #
    parseCSV() {
        local e array key value pair
        # Split.
        array=(${1//,/ })
        for e in "${array[@]}"
        do
            if [[ $e =~ \: ]];then
                pair=(${e//:/ })
                key=${pair[0]}
                value=${pair[1]}
                case $key in
                    # Key from User.
                    long) _long_option="$value" ;;
                    short) _short_option="$value" ;;
                    type) _type="$value" ;;
                    priority) _priority="$value" ;;
                    parameter) _parameter="$value" ;;
                    flag_option)
                        case $value in
                            reverse) _flag=0
                        esac
                        ;;
                    # Key for Internal only.
                    _parameter) _parameter="$value" ;;
                    _long_option) _long_option="$value" ;;
                    _short_option) _short_option="$value" ;;
                    _short_option_strlen) _short_option_strlen="$value" ;;
                    _type) _type="$value" ;;
                    _flag) _flag="$value" ;;
                esac
            fi
        done
    }

    # Populate global variable dari string format options.
    #
    # Contoh: `--long-options|-lo` `-o` `--verbose`
    #
    # Globals:
    #   Modified: _long_option, _short_option
    #
    # Arguments:
    #   $1: Value yang akan parsing.
    #
    # Returns:
    #   None
    #
    parseFormatOption() {
        if [[ "$1" =~ \| ]];then
            _long_option=$(echo "$1" | sed 's/|.*$//')
            _short_option=$(echo "$1" | sed 's/^.*|//')
        elif [[ "$1" =~ ^--[^-] ]];then
            _long_option="$1"
        elif [[ "$1" =~ ^-[^-] ]];then
            _short_option="$1"
        fi
    }

    # Populate global variable untuk membuat string yang bisa disort.
    #
    # Globals:
    #   Used: _priority, _sort_type, _alphabet
    #   Modified: _sort
    #
    # Arguments:
    #   $1: Value yang akan parsing berdasarkan CSV.
    #
    # Returns:
    #   None
    #
    populateSort() {
        local e array
        _sort=
        array=(${sort//,/ })
        for e in "${array[@]}"
        do
            case "$e" in
                priority) _sort+=$_priority ;;
                type) _sort+=$_sort_type ;;
                alphabet) _sort+=$_alphabet ;;
            esac
        done
    }

    # Populate global variable untuk membuat string yang digunakan dalam looping
    # `case)`.
    #
    # Globals:
    #   Used: _long_option, _short_option
    #   Modified: _case
    #
    # Arguments:
    #   $1: Tambahan string.
    #
    # Returns:
    #   None
    #
    populateCase() {
        local append="$1"
        _case=()
        if [[ ! $_long_option == '' ]];then
            _case+=("$_long_option$append")
        fi
        if [[ ! $_short_option == '' ]];then
            _case+=("$_short_option$append")
        fi
        _case=$(printf "%s" "${_case[@]/#/|}" | cut -c2-)
    }

    # Menggabungkan seluruh array `lines_n` menjadi satu string panjang `lines`.
    #
    # Globals:
    #   Used: lines_1 lines_2 lines_3 lines_4 lines_5 lines_6 lines_7 lines_8
    #         lines_9
    #   Modified: lines
    #
    # Arguments:
    #   None
    #
    # Returns:
    #   None
    #
    compileLines() {
        for e in "${lines_1[@]}"; do lines+="$e""
"; done
        for e in "${lines_2[@]}"; do lines+="$e""
"; done
        for e in "${lines_3[@]}"; do lines+="$e""
"; done
        for e in "${lines_4[@]}"; do lines+="$e""
"; done
        for e in "${lines_5[@]}"; do lines+="$e""
"; done
        for e in "${lines_6[@]}"; do lines+="$e""
"; done
        for e in "${lines_7[@]}"; do lines+="$e""
"; done
        for e in "${lines_8[@]}"; do lines+="$e""
"; done
        for e in "${lines_9[@]}"; do lines+="$e""
"; done
    }

    # Menghapus value dari parameter lines dan lines_n.
    #
    # Globals:
    #   Used: lines lines_1 lines_2 lines_3 lines_4 lines_5 lines_6 lines_7
    #         lines_8 lines_9
    #   Modified: lines lines_1 lines_2 lines_3 lines_4 lines_5 lines_6 lines_7
    #             lines_8 lines_9
    #
    # Arguments:
    #   None
    #
    # Returns:
    #   None
    #
    resetLines() {
        lines=; lines_1=(); lines_2=(); lines_3=(); lines_4=()
        lines_5=(); lines_6=(); lines_7=(); lines_8=(); lines_9=()
    }

    # Set default value for define.
    if [[ ! $ORIGINAL_ARGUMENTS == "" ]];then
        original_arguments=$ORIGINAL_ARGUMENTS
    else
        original_arguments='ORIGINAL_ARGUMENTS'
    fi
    if [[ ! $_NEW_ARGUMENTS == "" ]];then
        new_arguments=$_NEW_ARGUMENTS
    else
        new_arguments='_new_arguments'
    fi
    if [[ ! $_N == "" ]];then
        n=$_N
    else
        n='_n'
    fi
    if [[ ! $INDENT == "" ]];then
        ____=$INDENT
    else
        ____='    '
    fi

    # Start populate.
    for E in "${global[@]}"
    do
        # Clone array.
        eval _global=\(\"\$\{$E\[@\]\}\"\)
        for e in "${_global[@]}"
        do
            # Reset.
            _sort=
            _priority=
            # Reset CSV field.
            _parameter=
            _long_option=
            _short_option=
            _short_option_strlen=
            _type=
            _flag=1
            # Parsing now.
            case $E in
                FLAG) _type=flag; parseFormatOption "$e" ;;
                VALUE) _type=value; parseFormatOption "$e" ;;
                FLAG_VALUE) _type=flag_value; parseFormatOption "$e" ;;
                MULTIVALUE) _type=multivalue; parseFormatOption "$e" ;;
                INCREMENT) _type=increment; parseFormatOption "$e" ;;
                CSV)
                    parseCSV "$e"
                    if [[ $_type == '' ]];then
                        _type=flag
                    fi
                    ;;
            esac
            # Validate.
            if [[ ! $_long_option == '' ]];then
                if ! validateLongOptionName "$_long_option";then
                    echo Option name is not valid: '`'"$_long_option"'`'. >&2
                    continue
                fi
            fi
            if [[ ! $_short_option == '' ]];then
                if ! validateShortOptionName "$_short_option";then
                    echo Short option name is not valid: '`'"$_short_option"'`'. >&2
                    continue
                fi
            fi
            if [[ $_short_option == '' && $_long_option == '' ]];then
                echo Unknown format '`'"$e"'`'. >&2
                continue
            fi
            # Populate _parameter.
            if [[ $_parameter == '' ]];then
                # Long option first, then short option.
                if [[ ! $_long_option == '' ]];then
                    _parameter=$(buildParameter "$_long_option")
                else
                    _parameter=$(buildParameter "$_short_option")
                fi
                if [[ ${#_parameter} -gt $longest ]];then
                    longest=${#_parameter}
                fi
                i=$((${#_short_option}+${#_long_option}))
                if [[ ! $_long_option == '' && ! $_short_option == '' ]];then
                    i=$(($i+2)) # Dua merupakan koma dan spasi.
                fi
                if [[ $i -gt $longest2 ]];then
                    longest2=$i
                fi
            fi
            # Populate _sort.
            if [[ $_priority == '' ]];then
                _priority=6
                if [[ $_parameter == 'help' ]];then
                    _priority=4
                fi
                if [[ $_parameter == 'version' ]];then
                    _priority=5
                fi
            fi
            eval _sort_type=\$sort_type_$_type
            _alphabet=$(echo $_long_option | cut -c3-3)
            populateSort
            # Insert row to CSV.
            _row="$_sort , _parameter:$_parameter , _long_option:$_long_option , _short_option:$_short_option , _short_option_strlen:$_short_option_strlen , _type:$_type"
            if [[ $_type == 'flag' || $_type == 'flag_value' ]];then
                _row+=" , _flag:$_flag"
            fi
            csv_all+=("$_row")
            if [[ ! $_short_option == '' && $_short_option_strlen == 1 ]];then
                _alphabet=${_short_option//-/}
                populateSort
                csv_short_option_strlen_1+=("$_row")
                if [[ $_type == flag_value ]];then
                    csv_short_option_strlen_1_flag_value+=("$_row")
                fi
            fi
        done
    done

    IFS=$'\n' csv_all=($(sort <<<"${csv_all[*]}")); unset IFS
    IFS=$'\n' csv_short_option_strlen_1=($(sort <<<"${csv_short_option_strlen_1[*]}")); unset IFS
    IFS=$'\n' csv_short_option_strlen_1_flag_value=($(sort <<<"${csv_short_option_strlen_1_flag_value[*]}")); unset IFS

    if [[ "${#csv_all[@]}" -lt 1 ]];then
        return 1
    fi

    if [[ ! $no_hash_bang == 1 ]];then
        lines_1+=(                  '#!'"$path_shell")
        lines_1+=('')
    fi
    if [[ ! $no_original_arguments == 1 ]];then
        if [[ ! $clean == 1 ]];then
            lines_2+=(              '# Original arguments.')
        fi
        lines_2+=(                  $original_arguments'=("$@")')
        lines_2+=('')
    fi
    # Start first looping.
    for e in "${csv_all[@]}"
    do
        parseCSV "$e"
        if [[ ! $_short_option == '' && $_short_option_strlen == 1 ]];then
            _alphabet=${_short_option//-/}
            case "$_type" in
                flag)
                    optstring+=$_alphabet
                    let short_option_without_value++
                    ;;
                value)
                    optstring+=$_alphabet:
                    let short_option_with_value++
                    ;;
                flag_value)
                    optstring+=$_alphabet:
                    short_option_flag_value+=$_alphabet
                    let short_option_with_value++
                    ;;
                increment)
                    optstring+=$_alphabet
                    let short_option_without_value++
                    ;;
                multivalue)
                    optstring+=$_alphabet:
                    let short_option_with_value++
                    ;;
            esac
        fi
        if [[ $compact == 1 ]];then
            if [[ $clean == 1 ]];then
                _comment=
            else
                _comment=' # '$_type
            fi
        else
            if [[ ! $clean == 1 ]];then
                lines_5+=(          "$____$____"'# '$_type)
            fi
        fi
        case "$_type" in
            flag)
                populateCase
                if [[ $compact == 1 ]];then
                    lines_5+=(      "$____$____"$_case') '$_parameter'='$_flag'; shift ;;'"$_comment")
                else
                    lines_5+=(      "$____$____"$_case')')
                    lines_5+=(      "$____$____$____"$_parameter'='$_flag)
                    lines_5+=(      "$____$____$____"'shift')
                    lines_5+=(      "$____$____$____"';;')
                fi
                ;;
            value)
                populateCase '=*'
                if [[ $compact == 1 ]];then
                    lines_5+=(      "$____$____"$_case') '$_parameter'="${1#*=}"; shift ;;'"$_comment")
                else
                    lines_5+=(      "$____$____"$_case')')
                    lines_5+=(      "$____$____$____"$_parameter'="${1#*=}"')
                    lines_5+=(      "$____$____$____"'shift')
                    lines_5+=(      "$____$____$____"';;')
                fi
                populateCase
                if [[ $compact == 1 ]];then
                    _add='; else echo "Option $1 requires an argument." >&2'
                    if [[ $no_error_require_arguments == 1 ]];then
                        _add=
                    fi
                    lines_5+=(      "$____$____"$_case') if [[ ! $2 == "" && ! $2 =~ ^-[^-] ]]; then '$_parameter'="$2"; shift'"$_add"'; fi; shift ;;'"$_comment")
                else
                    lines_5+=(      "$____$____"$_case')')
                    lines_5+=(      "$____$____$____"'if [[ ! $2 == "" && ! $2 =~ ^-[^-] ]];then')
                    lines_5+=(      "$____$____$____$____"$_parameter'="$2"')
                    lines_5+=(      "$____$____$____$____"'shift')
                    if [[ ! $no_error_require_arguments == 1 ]];then
                        lines_5+=(  "$____$____$____"'else')
                        lines_5+=(  "$____$____$____$____"'echo "Option $1 requires an argument." >&2')
                    fi
                    lines_5+=(      "$____$____$____"'fi')
                    lines_5+=(      "$____$____$____"'shift')
                    lines_5+=(      "$____$____$____"';;')
                fi
                ;;
            flag_value)
                populateCase '=*'
                if [[ $compact == 1 ]];then
                    lines_5+=(      "$____$____"$_case') '$_parameter'="${1#*=}"; shift ;;'"$_comment")
                else
                    lines_5+=(      "$____$____"$_case')')
                    lines_5+=(      "$____$____$____"$_parameter'="${1#*=}"')
                    lines_5+=(      "$____$____$____"'shift')
                    lines_5+=(      "$____$____$____"';;')
                fi
                populateCase
                if [[ $compact == 1 ]];then
                    lines_5+=(      "$____$____"$_case') if [[ ! $2 == "" && ! $2 =~ ^-[^-] ]]; then '$_parameter'="$2"; shift; else '$_parameter'='$_flag'; fi; shift ;;'"$_comment")
                else
                    lines_5+=(      "$____$____"$_case')')
                    lines_5+=(      "$____$____$____"'if [[ ! $2 == "" && ! $2 =~ ^-[^-] ]];then')
                    lines_5+=(      "$____$____$____$____"$_parameter'="$2"')
                    lines_5+=(      "$____$____$____$____"'shift')
                    lines_5+=(      "$____$____$____"'else')
                    lines_5+=(      "$____$____$____$____"$_parameter'='$_flag)
                    lines_5+=(      "$____$____$____"'fi')
                    lines_5+=(      "$____$____$____"'shift')
                    lines_5+=(      "$____$____$____"';;')
                fi
                ;;
            increment)
                populateCase
                if [[ $compact == 1 ]];then
                    lines_5+=(      "$____$____"$_case') '$_parameter'="$(('$_parameter'+1))"; shift ;;'"$_comment")
                else
                    lines_5+=(      "$____$____"$_case')')
                    lines_5+=(      "$____$____$____"$_parameter'="$(('$_parameter'+1))"')
                    lines_5+=(      "$____$____$____"'shift')
                    lines_5+=(      "$____$____$____"';;')
                fi
                ;;
            multivalue)
                populateCase '=*'
                if [[ $compact == 1 ]];then
                    lines_5+=(      "$____$____"$_case') '$_parameter'+=("${1#*=}"); shift ;;'"$_comment")
                else
                    lines_5+=(      "$____$____"$_case')')
                    lines_5+=(      "$____$____$____"$_parameter'+=("${1#*=}")')
                    lines_5+=(      "$____$____$____"'shift')
                    lines_5+=(      "$____$____$____"';;')
                fi
                populateCase
                if [[ $compact == 1 ]];then
                    _add='; else echo "Option $1 requires an argument." >&2'
                    if [[ $no_error_require_arguments == 1 ]];then
                        _add=
                    fi
                    lines_5+=(      "$____$____"$_case') if [[ ! $2 == "" && ! $2 =~ ^-[^-] ]]; then '$_parameter'+=("$2"); shift'"$_add"'; fi; shift ;;'"$_comment")
                else
                    lines_5+=(      "$____$____"$_case')')
                    lines_5+=(      "$____$____$____"'if [[ ! $2 == "" && ! $2 =~ ^-[^-] ]];then')
                    lines_5+=(      "$____$____$____$____"$_parameter'+=("$2")')
                    lines_5+=(      "$____$____$____$____"'shift')
                    if [[ ! $no_error_require_arguments == 1 ]];then
                        lines_5+=(  "$____$____$____"'else')
                        lines_5+=(  "$____$____$____$____"'echo "Option $1 requires an argument." >&2')
                    fi
                    lines_5+=(      "$____$____$____"'fi')
                    lines_5+=(      "$____$____$____"'shift')
                    lines_5+=(      "$____$____$____"';;')
                fi
                ;;
        esac
    done
    print_new_arguments=1
    if [[ $no_rebuild_arguments == 1 ]];then
        print_new_arguments=0
    fi
    if [[ $short_option_without_value -gt 1 || $short_option_with_value -gt 0 ]];then
        print_new_arguments=1
    fi
    if [[ $end_options_double_dash == 1 || $end_options_first_operand == 1 ]];then
        print_new_arguments=1
    fi
    if [[ $print_new_arguments == 1 ]];then
        temporary_variable+=(       "$new_arguments"'=()')
    fi
    if [[ ! $clean == 1 ]];then
        lines_4+=(                  '# Processing standalone options.')
    fi
    lines_4+=(                      'while [[ $# -gt 0 ]]; do')
    lines_4+=(                      "$____"'case "$1" in')
    # Prepare repeat code.
    if [[ $end_options_double_dash == 1 || $end_options_first_operand == 1 ]];then
        # Karena print_new_arguments=1, maka tambahkan langsung new_arguments.
        _array=()
        _array+=(                   'while [[ $# -gt 0 ]]; do')
        _array+=(                   "$____"'case "$1" in')
        if [[ $compact == 1 ]];then
            _array+=(               "$____$____"'*) '"$new_arguments"'+=("$1"); shift ;;')
        else
            _array+=(               "$____$____"'*)')
            _array+=(               "$____$____$____""$new_arguments"'+=("$1")')
            _array+=(               "$____$____$____"'shift')
            _array+=(               "$____$____$____"';;')
        fi
        _array+=(                   "$____"'esac')
        _array+=(                   'done')
    fi
    # Double dash.
    if [[ $end_options_double_dash == 1 ]];then
        if [[ $short_option_without_value -gt 1 || $short_option_with_value -gt 0 ]];then
            # Double dash akan dilanjutkan di looping kedua.
            # Jadi double dash perlu dimasukkan juga ke `_new_arguments`.
            lines_6+=(              "$____$____"'--)')
        else
            if [[ $compact == 1 ]];then
                lines_6+=(          "$____$____"'--) shift')
            else
                lines_6+=(          "$____$____"'--)')
                lines_6+=(          "$____$____$____"'shift')
            fi
        fi
        for e in "${_array[@]}"
        do
            lines_6+=(              "$____$____$____""$e")
        done
        lines_6+=(                  "$____$____$____"';;')
    fi
    # Invalid long options with double dash.
    if [[ ! $no_error_invalid_options == 1 ]];then
        if [[ $compact == 1 ]];then
            lines_6+=(              "$____$____"'--[^-]*) echo "Invalid option: $1" >&2; shift ;;')
        else
            lines_6+=(              "$____$____"'--[^-]*)')
            lines_6+=(              "$____$____$____"'echo "Invalid option: $1" >&2')
            lines_6+=(              "$____$____$____"'shift')
            lines_6+=(              "$____$____$____"';;')
        fi
    fi
    # Asterix.
    if [[  $end_options_first_operand == 1 ]];then
        lines_6+=(                  "$____$____"'*)')
        for e in "${_array[@]}"
        do
            lines_6+=(              "$____$____$____""$e")
        done
        lines_6+=(                  "$____$____$____"';;')
    else
        if [[ $compact == 1 ]];then
            _add=
            if [[ $print_new_arguments == 1 ]];then
                _add=' '"$new_arguments"'+=("$1");'
            fi
            lines_6+=(              "$____$____"'*)'"$_add"' shift ;;')
        else
            lines_6+=(              "$____$____"'*)')
            if [[ $print_new_arguments == 1 ]];then
                lines_6+=(          "$____$____$____""$new_arguments"'+=("$1")')
            fi
            lines_6+=(              "$____$____$____"'shift')
            lines_6+=(              "$____$____$____"';;')
        fi
    fi
    lines_6+=(                      "$____"'esac')
    lines_6+=(                      'done')
    lines_6+=('')
    if [[ $print_new_arguments == 1 ]];then
        lines_6+=(                  'set -- "${'"$new_arguments"'[@]}"')
        lines_6+=('')
    fi
    # Start second looping.
    if [[ $short_option_without_value -gt 1 || $short_option_with_value -gt 0 ]];then
        if [[ ! $clean == 1 ]];then
            lines_7+=(              '# Truncate.')
        fi
        lines_7+=(                  "$new_arguments"'=()')
        lines_7+=('')
        if [[ ! $clean == 1 ]];then
            lines_7+=(              '# Processing compiled single character options.')
        fi
        lines_7+=(                  'while [[ $# -gt 0 ]]; do')
        lines_7+=(                  "$____"'case "$1" in')
        if [[ $compact == 1 ]];then
            lines_7+=(              "$____$____"'-[^-]*) OPTIND=1')
        else
            lines_7+=(              "$____$____"'-[^-]*)')
            lines_7+=(              "$____$____$____"'OPTIND=1')
        fi
        lines_7+=(                  "$____$____$____"'while getopts "':$optstring'" opt; do')
        lines_7+=(                  "$____$____$____$____"'case $opt in')
        lines_9+=(                  "$____$____$____$____"'esac')
        lines_9+=(                  "$____$____$____"'done')
        if [[ $end_options_double_dash == 1 ]];then
            temporary_variable+=(   "$n"'=')
            lines_9+=(              "$____$____$____""$n"'="$((OPTIND-1))"')
            lines_9+=(              "$____$____$____""$n"'=${!'"$n"'}')
        fi
        lines_9+=(                  "$____$____$____"'shift "$((OPTIND-1))"')
        if [[ $end_options_double_dash == 1 ]];then
            lines_9+=(              "$____$____$____"'if [[ "$'"$n"'" == '"'"'--'"'"' ]];then')
            for e in "${_array[@]}"
            do
                lines_9+=(          "$____$____$____$____""$e")
            done
            lines_9+=(              "$____$____$____"'fi')
        fi
        lines_9+=(                  "$____$____$____"';;')
        # Double dash.
        if [[ $end_options_double_dash == 1 ]];then
            if [[ $compact == 1 ]];then
                lines_9+=(          "$____$____"'--) shift')
            else
                lines_9+=(          "$____$____"'--)')
                lines_9+=(          "$____$____$____"'shift')
            fi
            for e in "${_array[@]}"
            do
                lines_9+=(          "$____$____$____""$e")
            done
            lines_9+=(              "$____$____$____"';;')
        fi
        # Asterix.
        if [[  $end_options_first_operand == 1 ]];then
            lines_9+=(              "$____$____"'*)')
            for e in "${_array[@]}"
            do
                lines_9+=(          "$____$____$____""$e")
            done
            lines_9+=(              "$____$____$____"';;')
        else
            if [[ $compact == 1 ]];then
                lines_9+=(          "$____$____"'*) '"$new_arguments"'+=("$1"); shift ;;')
            else
                lines_9+=(          "$____$____"'*)')
                lines_9+=(          "$____$____$____""$new_arguments"'+=("$1")')
                lines_9+=(          "$____$____$____"'shift')
                lines_9+=(          "$____$____$____"';;')
            fi
        fi
        lines_9+=(                  "$____"'esac')
        lines_9+=(                  'done')
        lines_9+=('')
        lines_9+=(                  'set -- "${'"$new_arguments"'[@]}"')
        lines_9+=('')
        for e in "${csv_short_option_strlen_1[@]}"; do
            parseCSV "$e"
            _alphabet=${_short_option//-/}
            _add=
            case "$_type" in
                flag)
                    _add=$_parameter'='$_flag
                    ;;
                value)
                    _add=$_parameter'="$OPTARG"'
                    ;;
                flag_value)
                    _add=$_parameter'="$OPTARG"'
                    ;;
                increment)
                    _add=$_parameter'="$(('$_parameter'+1))"'
                    ;;
                multivalue)
                    _add=$_parameter'+=("$OPTARG")'
                    ;;
            esac
            if [[ $compact == 1 ]];then
                if [[ $clean == 1 ]];then
                    _comment=
                else
                    _comment=' # '$_type
                fi
            else
                if [[ ! $clean == 1 ]];then
                    lines_8+=(      "$____$____$____$____$____"'# '$_type)
                fi
            fi
            if [[ $compact == 1 ]];then
                lines_8+=(          "$____$____$____$____$____"$_alphabet')'' '"$_add"' ;;'"$_comment")
            else

                lines_8+=(          "$____$____$____$____$____"$_alphabet')')
                lines_8+=(          "$____$____$____$____$____$____""$_add")
                lines_8+=(          "$____$____$____$____$____$____"';;')
            fi
        done
        # Question.
        if [[ ! $no_error_invalid_options == 1 ]];then
            if [[ $compact == 1 ]];then
                lines_8+=(          "$____$____$____$____$____"'\?) echo "Invalid option: -$OPTARG" >&2 ;;')
            else
                lines_8+=(          "$____$____$____$____$____"'\?)')
                lines_8+=(          "$____$____$____$____$____$____"'echo "Invalid option: -$OPTARG" >&2')
                lines_8+=(          "$____$____$____$____$____$____"';;')
            fi
        fi
        if [[ ${#csv_short_option_strlen_1_flag_value[@]} -gt 0 ]];then
            _array=()
            _array+=(               'case $OPTARG in')
            for e in "${csv_short_option_strlen_1_flag_value[@]}"; do
                parseCSV "$e"
                _alphabet=${_short_option//-/}
                if [[ $compact == 1 ]];then
                    _array+=(       "$____"$_alphabet') '$_parameter'='$_flag' ;;')
                else
                    _array+=(       "$____"$_alphabet')')
                    _array+=(       "$____$____"$_parameter'='$_flag)
                    _array+=(       "$____$____"';;')
                fi
            done
            _array+=(               'esac')
        fi
        # Colon.
        if [[ ${#csv_short_option_strlen_1_flag_value[@]} -gt 0 ]];then
            lines_8+=("$____$____$____$____$____"':)')
            _add=
            if [[ ! $no_error_require_arguments == 1 ]];then
                _add="$____"
                if [[ $compact == 1 ]];then
                    lines_8+=(      "$____$____$____$____$____$____"'if [[ ! $OPTARG =~ ['$short_option_flag_value'] ]];then echo "Option -$OPTARG requires an argument." >&2')
                else
                    lines_8+=(      "$____$____$____$____$____$____"'if [[ ! $OPTARG =~ ['$short_option_flag_value'] ]];then')
                    lines_8+=(      "$____$____$____$____$____$____"'    echo "Option -$OPTARG requires an argument." >&2')
                fi
                lines_8+=(          "$____$____$____$____$____$____"'else')
            fi
            for e in "${_array[@]}"
            do
                lines_8+=(          "$_add$____$____$____$____$____$____""$e")
            done
            if [[ ! $no_error_require_arguments == 1 ]];then
                lines_8+=(          "$____$____$____$____$____$____"'fi')
            fi
            lines_8+=(              "$____$____$____$____$____$____"';;')
        elif [[ ! $no_error_require_arguments == 1 ]];then
            lines_8+=(              "$____$____$____$____$____"':) echo "Option -$OPTARG requires an argument." >&2 ;;')
        fi
    fi
    if [[ ${#temporary_variable[@]} -gt 0 ]];then
        if [[ ! $clean == 1 ]];then
            lines_3+=(              '# Temporary variable.')
        fi
        for e in "${temporary_variable[@]}"
        do
            lines_3+=(              "$e")
            lines_9+=(                  'unset '"${e%=*}")
        done
        lines_3+=('')
    fi
    if [[ ! $clean == 1 ]];then
        lines_9+=(                  '# End of generated code by CodeGeneratorParseOptions().')
    fi
    # Output.
    compileLines
    if [[ ! $output_file == '' ]];then
        echo -n "$lines" > $output_file
    else
        echo -n "$lines"
    fi
    if [[ ! $debug_file == '' ]];then
        resetLines
        lines_1+=(                  '#!'"$path_shell")
        lines_1+=('')
        lines_1+=(                  'normal="$(tput sgr0)"')
        lines_1+=(                  'red="$(tput setaf 1)"')
        lines_1+=(                  'yellow="$(tput setaf 3)"')
        lines_1+=(                  'cyan="$(tput setaf 6)"')
        lines_1+=(                  'magenta="$(tput setaf 5)"')
        lines_1+=('')
        lines_2+=(                  'echo')
        lines_2+=(                  'echo ${yellow}'"'# Options'"'${normal}')
        lines_2+=(                  'echo')
        for e in "${csv_all[@]}"
        do
            parseCSV "$e"
            case $_type in
                multivalue) _line='echo -n' ;;
                *) _line='echo'"   " ;;
            esac
            _array=($_short_option $_long_option)
            _add=$(printf "%s" "${_array[@]/#/, }" | cut -c3-)
            j=
            for (( i=0; i < (( ${longest2} - ${#_add} )) ; i++ )); do j+="."; done
            j=" "$j" "
            if [[ $j == " . " ]];then j="   "; elif [[ $j == " .. " ]];then j="    "; fi
            _line+=' ${red}'"$_add"'${normal}"'"$j"'"${cyan}\$'"$_parameter"'${normal}'
            j=
            for (( i=0; i < (( ${longest} - ${#_parameter} )) ; i++ )); do j+="."; done
            j=" "$j" "
            if [[ $j == " . " ]];then j="   "; elif [[ $j == " .. " ]];then j="    "; fi
            _line+='"'"$j"'= "'
            case $_type in
                multivalue)
                    _line+='"( "'
                    lines_5+=(      "$_line")
                    lines_5+=(            'for _e_ in "${'"$_parameter"'[@]}"; do if [[ $_e_ =~ " " ]];then echo -n \"${magenta}"$_e_"${normal}\"" ";else echo -n ${magenta}"$_e_"${normal}" ";fi;done')
                    lines_5+=(      'echo ")"')
                    ;;
                *)
                    _line+='${magenta}$'"$_parameter"'${normal}'
                    lines_5+=(      "$_line")
                    ;;
            esac
        done
        lines_5+=('')
        lines_6+=(                  'echo')
        lines_6+=(                  "echo \${yellow}'# New Arguments (Operand)'\${normal}")
        lines_6+=(                  'echo')
        lines_6+=(                  'echo ${cyan}\$1${normal} = ${magenta}$1${normal}')
        lines_6+=(                  'echo ${cyan}\$2${normal} = ${magenta}$2${normal}')
        lines_6+=(                  'echo ${cyan}\$3${normal} = ${magenta}$3${normal}')
        lines_6+=(                  'echo ${cyan}\$4${normal} = ${magenta}$4${normal}')
        lines_6+=(                  'echo ${cyan}\$5${normal} = ${magenta}$5${normal}')
        lines_6+=(                  'echo ${cyan}\$6${normal} = ${magenta}$6${normal}')
        lines_6+=(                  'echo ${cyan}\$7${normal} = ${magenta}$7${normal}')
        lines_6+=(                  'echo ${cyan}\$8${normal} = ${magenta}$8${normal}')
        lines_6+=(                  'echo ${cyan}\$9${normal} = ${magenta}$9${normal}')
        compileLines
        echo -n "$lines" > $debug_file
    fi
}
