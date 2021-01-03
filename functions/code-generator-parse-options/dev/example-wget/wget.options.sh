#!/bin/bash

FLAG=(
    '--version|-V'
    '--help|-h'
    '--background|-b'
    '--debug|-d'
    '--quiet|-q'
    '--no-host-directories|-nH'
)
VALUE=(
    '--output-file|-o'
    '--output-document|-O'
    '--append-output|-a'
)
MULTIVALUE=(
    '--execute|-e'
)

# Stop here.
source $(dirname $0)/../code-generator-parse-options.function.sh
CodeGeneratorParseOptions $@
