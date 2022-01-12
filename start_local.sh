#!/usr/bin/env bash
# Please ensure that poetry is installed in your local machine
echo "Exporting Environment Variables..."
export APP_ENVIRONMENT=STG
export SLACK_WEBHOOK_URL=
export ALLOWED_HOSTS=["*"]
echo "Environment Variables Exported"

echo "Installing Dependencies..."
poetry install --no-root
echo "Dependencies Installed"

echo "Starting service..."
gunicorn glitor.main:app -b 0.0.0.0:10000 -k uvicorn.workers.UvicornWorker
echo "Service Started!"