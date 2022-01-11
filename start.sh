#!/usr/bin/env bash
echo "Installing Poetry.."
curl -sSL https://raw.githubusercontent.com/python-poetry/poetry/master/get-poetry.py | python3 -

echo "Poetry Version"
poetry --version
echo "Poetry Installed!"

echo "Export Environment Variables..."
export APP_ENVIRONMENT=STG
export SLACK_WEBHOOK_URL=
export ALLOWED_HOSTS=ALLOWED_HOSTS=["*"]
echo "Environment Variables Exported"

echo "Installing Dependencies..."
poetry install --no-root
echo "Dependencies Installed"

echo "Starting service..."
gunicorn main:app -b 0.0.0.0:10000 -k uvicorn.workers.UvicornWorker --daemon &
echo "Service Started!"