#!/usr/bin/env bash

curl --silent "https://api.github.com/repos/moinsam/glitor/releases/latest" \
| grep '"tag_name":' \
| sed -E 's/.*"([^"]+)".*/\1/' \
| xargs -I {} curl -sOL "https://github.com/moinsam/glitor/archive/"{}'.tar.gz'

tarball="$(find . -name "*.tar.gz")"
tar -xzf $tarball