#!/bin/bash
while IFS= read line; do
    # echo "$line"
    version=`cat "$line" | sed -n '/_printVersion(/,+1p' | sed -n 2p | grep -o -P "'\K([0-9\.]+)"`
    echo "$version $line"
done <<< `git status --porcelain | grep '^M\s' | sed s,'^M\s',,g | cut -d' ' -f2`
