# Code Generator for Parsing Options in Command Line Arguments

Attention:

The generated code just for parsing only, not include validation.

## Getting Started

Navigate to `example-simple` directory.

```
cd example-simple
```

Look for `simple.option.sh` file, just execute it.

```
./simple.options.sh
```

You'll see the generated code in stdout:

```
#!/bin/bash

# Original arguments.
ORIGINAL_ARGUMENTS=("$@")

# Temporary variable.
_new_arguments=()

# Processing standalone options.
while [[ $# -gt 0 ]]; do
    case "$1" in
        # value
        --output-file=*)
            output_file="${1#*=}"
            shift
            ;;
        --output-file)
            if [[ ! $2 == "" && ! $2 =~ ^-[^-] ]];then
                output_file="$2"
                shift
            else
                echo "Option $1 requires an argument." >&2
            fi
            shift
            ;;
        # flag
        --quiet|-q)
            quiet=1
            shift
            ;;
        --[^-]*)
            echo "Invalid option: $1" >&2
            shift
            ;;
        *)
            _new_arguments+=("$1")
            shift
            ;;
    esac
done

set -- "${_new_arguments[@]}"

unset _new_arguments
# End of generated code by CodeGeneratorParseOptions().
```

The contents of that file (`simple.options.sh`) is:

```
#!/bin/bash

FLAG=(
    '--quiet|-q'
)
VALUE=(
    --output-file
)

# Stop here.
source $(dirname $0)/../code-generator-parse-options.function.sh
CodeGeneratorParseOptions --without-end-options-double-dash $@
```

Add your own option in the FLAG or VALUE array, and execute that file again.

The generated code will be updated.

Any arguments to `simple.options.sh` file are passed to the `CodeGeneratorParseOptions()` function. Lets come up with another variation.

```
./simple.options.sh --compact --clean --no-rebuild-arguments --no-original-arguments --no-error-invalid-options --no-error-require-arguments
```

The updated generated code is:

```
#!/bin/bash

while [[ $# -gt 0 ]]; do
    case "$1" in
        --output-file=*) output_file="${1#*=}"; shift ;;
        --output-file) if [[ ! $2 == "" && ! $2 =~ ^-[^-] ]]; then output_file="$2"; shift; fi; shift ;;
        --quiet|-q) quiet=1; shift ;;
        *) shift ;;
    esac
done

```

**You can embed that generated code into your shell script at the beginning**.

Navigate to `example-wget` and `example-ssh` directory to learn more deeply.

See the `DOCUMENTATION.md` file for a complete guide.

# Reference

https://www.gnu.org/software/bash/manual/html_node/Shell-Parameter-Expansion.html

https://unix.stackexchange.com/questions/96703/what-is-a-non-option-argument
