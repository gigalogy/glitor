#!/usr/bin/env bash
echo "Installing Poetry.."
curl -sSL https://raw.githubusercontent.com/python-poetry/poetry/master/get-poetry.py | python3 -

echo "Poetry Version"
poetry --version
poetry config virtualenvs.create true
poetry config virtualenvs.in-project true
poetry config virtualenvs.path .venv
source "$( poetry env list --full-path )/bin/activate"
echo "Poetry Installed!"

echo "Installing Dependencies..."
poetry install --no-root
echo "Dependencies Installed"

echo "Starting service..."
gunicorn glitor.main:app -b 0.0.0.0:10000 -k uvicorn.workers.UvicornWorker --daemon &
echo "Service Started!"