#!/bin/bash

FLAG=(
    '-4'
)
VALUE=(
    '-l'
)
MULTIVALUE=(
    '-o'
)
INCREMENT=(
    '-v'
)

# Stop here.
source $(dirname $0)/../code-generator-parse-options.function.sh
CodeGeneratorParseOptions $@
