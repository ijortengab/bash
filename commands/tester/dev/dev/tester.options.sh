#!/bin/bash
VALUE=(
    # Output.
    "--output|-o"
)
MULTIVALUE=(
    # File Exists.
    "--file-exists|-fe"
    # File Not Exists.
    "--file-not-exists|-fne"
)

source $(dirname $0)/../../../../functions/code-generator-parse-options/dev/code-generator-parse-options.function.sh

CodeGeneratorParseOptions \
    --compact \
    --no-error-invalid-options \
    --no-error-require-arguments \
    --no-hash-bang \
    --no-original-arguments \
    --without-end-options-double-dash \
    --clean \
    --output-file tester.parse_options.sh \
    --debug-file tester.debug.sh \
    $@
