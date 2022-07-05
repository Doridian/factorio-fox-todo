#!/bin/bash

set -x

VERSION="$(git describe --tags 2> /dev/null)"

if [ -z "$VERSION" ]
then
    VERSION="99.99.99"
fi

sed "s~99\\.99\\.98~$VERSION" -i info.json
sed "s~M.version = .*$~M.version = \"$VERSION\"" -i config.lua

cat info.json
cat config.lua

git archive HEAD --prefix=fox-todo/ --format=zip -o "fox-todo_$VERSION.zip"
