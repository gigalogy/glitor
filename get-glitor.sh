#!/usr/bin/env bash

echo "Export Environment Variables..."
export APP_ENVIRONMENT=STG
# We have to set this env explicitly in row data of ec2
export SLACK_WEBHOOK_URL=''
export ALLOWED_HOSTS=["*"]
export CPU_THRESHOLD=90
export MEMORY_THRESHOLD=75
echo "Environment Variables Exported"

echo "Glitor Downloading..."
curl -u $USER --silent "https://api.github.com/repos/gigalogy/glitor/releases/latest" \
| grep '"tag_name":' \
| sed -E 's/.*"([^"]+)".*/\1/' \
| xargs -I {} curl -sOL "https://github.com/gigalogy/glitor/archive/"{}'.tar.gz'

echo "Glitor Downloaded!"

tarball="$(find . -maxdepth 1 -name "*.tar.gz")"
tar --owner 0 -xzf $tarball

mv glitor-* glitor
chown -R $USER glitor

cd glitor

sh start.sh