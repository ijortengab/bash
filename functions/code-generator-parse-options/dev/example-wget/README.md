# Shell script development suggestions

## Key Learning

> By default, the Code generated by `CodeGeneratorParseOptions` function interprets a double hyphen as the end of options.

## Development

Assume that we are going to create a shell script like the `wget` command.

Let's Define our options in the `wget.options.sh` file.

The contents of `wget.options.sh` file is:

```
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

```

Any arguments to `wget.options.sh` file are passed to the `CodeGeneratorParseOptions()` function.

Lets using `--output-file` and `--debug-file` options to produce file that will be embedded.

```
./wget.options.sh --output-file wget.parse_options.sh  --debug-file wget.debug.sh
```

Now we have two new files named `wget.parse_options.sh` and `wget.debug.sh`.

Create a file for your development shell script. For example a file named `wget.dev.sh`.

Add two lines inside `wget.dev.sh` file for embedding.

```
source $(dirname $0)/wget.parse_options.sh
source $(dirname $0)/wget.debug.sh
```

Provide arguments for `wget.dev.sh` with many variations.

```
./wget.dev.sh -qO- http://ijortengab.id
./wget.dev.sh -qO- http://ijortengab.id -- -a -b -c
```

By default, the Code generated by `CodeGeneratorParseOptions` function interprets a double hyphen as the end of options.

You can now start developing your shell script in the `wget.dev.sh` file.

## Build

Tips if you have done developing your shell script. Give your stable script a name, for example `wget.sh`.

```
touch wget.sh
chmod +x wget.sh
```

Rerun the `wget.options.sh` with `--no-hash-bang`, `--compact`, and `--clean` option.

```
./wget.options.sh --no-hash-bang --compact --clean --output-file wget.parse_options.min.txt
```

This creates a minified version of `wget.parse_options.sh` file and ready to embed.

Replace this line:

```
source $(dirname $0)/wget.parse_options.sh
```

with the contents of `wget.parse_options.min.txt` file, then release your stable script.

```
FILE2=$(<wget.dev.sh) && \
FILE1=$(<wget.parse_options.min.txt) && \
echo "${FILE2//source \$(dirname \$0)\/wget.parse_options.sh/$FILE1}" > wget.sh
```

Don't forget to remove the debug line:

```
source $(dirname $0)/wget.debug.sh
```

with execute `sed`.

```
sed -i '/source \$(dirname \$0)\/wget.debug.sh/d' ./wget.sh
```

Now, your stable script is ready.

```
./wget.sh
```