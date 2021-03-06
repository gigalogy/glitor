#!/usr/bin/env bash
echo "Installing Poetry.."
curl -sSL https://raw.githubusercontent.com/python-poetry/poetry/master/get-poetry.py | python3 -

source $HOME/.poetry/env
echo "Poetry Version"
poetry --version
poetry config virtualenvs.create true
poetry config virtualenvs.in-project true
poetry config virtualenvs.path .venv
chmod +x .venv/bin/activate
source .venv/bin/activate
echo "Poetry Installed!"

echo "Installing Dependencies..."
poetry install --no-root
echo "Dependencies Installed"

echo "Starting service..."
gunicorn glitor.main:app -k uvicorn.workers.UvicornWorker --daemon &
echo "Service Started!"