#!/usr/bin/env bash

echo "Export Environment Variables..."
export APP_ENVIRONMENT=STG
export SLACK_WEBHOOK_URL=
export ALLOWED_HOSTS=ALLOWED_HOSTS=["*"]
echo "Environment Variables Exported"

echo "Glitor Downloading..."
curl --silent "https://api.github.com/repos/moinsam/glitor/releases/latest" \
| grep '"tag_name":' \
| sed -E 's/.*"([^"]+)".*/\1/' \
| xargs -I {} curl -sOL "https://github.com/moinsam/glitor/archive/"{}'.tar.gz'

echo "Glitor Downloaded!"

newdirname=~/glitor
if [ -d "$newdirname" ]; then
echo "Directory already exists" ;
else
`mkdir -p $newdirname`;
echo "$newdirname directory is created"
fi
tarball="$(find . -name "*.tar.gz")"
tar -xzf $tarball -C ~/glitor
cd $newdirname
chmod +x start.sh
sh start.sh