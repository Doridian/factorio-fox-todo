#!/bin/bash

set -x

VERSION="$(git describe --tags 2> /dev/null)"

set -e

if [ -z "$VERSION" ]
then
    VERSION="99.99.99"
fi

PROJECT_DIR="$(pwd)"

sed "s~99\\.99\\.98~$VERSION~" -i info.json
sed "s~M.version = .*$~M.version = \"$VERSION\"~" -i config.lua

TMP_DIR="$(mktemp -d)"

mkdir -p dist
DIST_DIR="$PROJECT_DIR/dist"


rm -f "$DIST_DIR/fox-todo_$VERSION.zip"

ln -s "$PROJECT_DIR" "$TMP_DIR/fox-todo"
cd "$TMP_DIR"
zip "$DIST_DIR/fox-todo_$VERSION.zip" -v -r './fox-todo' -x './fox-todo/.gitignore' -x './fox-todo/.git' -x './fox-todo/.git/*' -x './fox-todo/.github' -x './fox-todo/.github/*'
cd "$PROJECT_DIR"

rm -rf "$TMP_DIR"
