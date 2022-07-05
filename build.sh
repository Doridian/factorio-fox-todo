#!/bin/bash

set -x

VERSION="$(git describe --tags 2> /dev/null)"

set -e

if [ -z "$VERSION" ]
then
    VERSION="99.99.99"
fi

sed "s~99\\.99\\.98~$VERSION~" -i info.json
sed "s~M.version = .*$~M.version = \"$VERSION\"~" -i config.lua

git add info.json config.lua
git commit -m "AUTOMATED RELEASE"

mkdir -p dist
git archive HEAD --prefix=fox-todo/ --format=zip -o "dist/fox-todo_$VERSION.zip"
