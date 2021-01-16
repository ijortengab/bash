#!/bin/bash
chmod +x tester.options.sh
./tester.options.sh
# Replace line.
touch ../tester.sh
chmod +x ../tester.sh
SOURCE=$(<tester.dev.sh)
FILE_PARSE_OPTIONS=$(<tester.parse_options.sh)
FILE_FUNCTIONS=$(<tester.functions.sh)
SOURCE="${SOURCE//source \$(dirname \$0)\/tester.parse_options.sh/$FILE_PARSE_OPTIONS}"
SOURCE="${SOURCE//source \$(dirname \$0)\/tester.functions.sh/$FILE_FUNCTIONS}"
echo "${SOURCE}" > ../tester.sh
# Delete line.
sed -i '/var-dump\.function\.sh/d' ../tester.sh
sed -i '/tester\.debug\.sh/d' ../tester.sh
sed -i '/VarDump/d' ../tester.sh
# Add to $PATH
[ -d ~/bin ] && cp -r ../tester.sh ~/bin/tester
