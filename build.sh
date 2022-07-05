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

mkdir -p dist/zipsrc
ln -s . dist/zipsrc/fox-todo
cd dist/zipsrc
zip "../fox-todo_$VERSION.zip" -r './fox-todo' -x './fox-todo/dist' -x './fox-todo/dist/*'
cd ../..
