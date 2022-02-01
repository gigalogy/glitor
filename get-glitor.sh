#!/usr/bin/env bash

echo "Export Environment Variables..."
export APP_ENVIRONMENT=STG
# We have to set this env explicitly in row data of ec2
# export SLACK_WEBHOOK_URL=
export ALLOWED_HOSTS=["*"]
echo "Environment Variables Exported"

echo "Glitor Downloading..."
curl --silent "https://api.github.com/repos/gigalogy/glitor/releases/latest" \
| grep '"tag_name":' \
| sed -E 's/.*"([^"]+)".*/\1/' \
| xargs -I {} curl -sOL "https://github.com/gigalogy/glitor/archive/"{}'.tar.gz'

echo "Glitor Downloaded!"

tarball="$(find . -name "*.tar.gz")"
tar -xzf $tarball

mv glitor-* glitor

cd glitor

sh start.sh