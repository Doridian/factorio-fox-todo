#!/bin/bash

set -x

VERSION="$(git describe --tags 2> /dev/null)"
DO_RELEASE=1

set -e

if [ -z "$VERSION" ]
then
    VERSION="99.99.99"
    DO_RELEASE=0
fi

PROJECT_DIR="$(pwd)"

sed "s~99\\.99\\.98~$VERSION~" -i info.json
sed "s~M.version = .*$~M.version = \"$VERSION\"~" -i config.lua

TMP_DIR="$(mktemp -d)"

mkdir -p dist
DIST_DIR="$PROJECT_DIR/dist"

OUTPUT_ZIP="$DIST_DIR/fox-todo_$VERSION.zip"

# Remove any old artifact
rm -f "$OUTPUT_ZIP"

# Link for the ZIP structure to be fox-todo/.... as Factorio requires
ln -s "$PROJECT_DIR" "$TMP_DIR/fox-todo"
cd "$TMP_DIR"
zip "$OUTPUT_ZIP" -v -r './fox-todo' -x './fox-todo/.gitignore' -x './fox-todo/.git' -x './fox-todo/.git/*' -x './fox-todo/.github' -x './fox-todo/.github/*' -x './fox-todo/dist' -x './fox-todo/dist/*'
cd "$PROJECT_DIR"
rm -rf "$TMP_DIR"

# Upload to mod portal
if [ $DO_RELEASE -eq 1 ]
then
    set +x
    UPLOAD_RES="$(curl -sf -H "Authorization: Bearer $UPLOAD_API_KEY" 'https://mods.factorio.com/api/v2/mods/releases/init_upload' -F 'mod=fox-todo')"
    UPLOAD_URL="$(echo "$UPLOAD_RES" | jq -r .upload_url)"
    curl -sf "$UPLOAD_URL" -F "file=@$OUTPUT_ZIP"
    set -x
fi
