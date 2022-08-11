echo "Export Environment Variables..."
export APP_ENVIRONMENT=PROD
export SLACK_WEBHOOK_URL=<SLACK_WEBHOOK_URL>
export ALLOWED_HOSTS=["*"]
export CPU_THRESHOLD=200
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

echo "Installing Poetry.."
curl -sSL https://install.python-poetry.org | python3 -
poetry --version
poetry config virtualenvs.create true
poetry config virtualenvs.in-project true
poetry config virtualenvs.path .venv
echo "Poetry Installed"

echo "Installing Dependencies..."
poetry install --no-root
echo "Dependencies Installed"

source .venv/bin/activate
echo "Starting service..."
gunicorn glitor.main:app -k uvicorn.workers.UvicornWorker --daemon &
echo "Service Started!"
