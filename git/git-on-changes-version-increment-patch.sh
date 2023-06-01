#!/bin/bash
while IFS= read line; do
    # echo "$line"
    version=`cat "$line" | sed -n '/_printVersion(/,+1p' | sed -n 2p | grep -o -P "'\K([0-9\.]+)"`
    major=`echo "$version" | cut -d. -f1`
    minor=`echo "$version" | cut -d. -f2`
    patch=`echo "$version" | cut -d. -f3`
    patch=$((patch + 1))
    newversion="${major}.${minor}.${patch}"
    version_quoted=$(sed "s/\./\\\./g" <<< "$version")
    sed -i 's,'$version_quoted','$newversion',' "$line"
    echo "$line $version $newversion"
done <<< `git status --porcelain | grep '^\sM' | sed s,'^\sM',,g | cut -d' ' -f2`
