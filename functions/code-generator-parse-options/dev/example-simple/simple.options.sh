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
