import os

from pydantic import BaseSettings


class BaseConfig(BaseSettings):
    app_name: str = "Gigalogy Platform Monitor API"
    app_description: str = "Monitors all the containers running in Gigalogy platform and send slack notification when something goes wrong"
    app_version: str = "v1"
    env_name: str = os.environ["APP_ENVIRONMENT"]
    allowed_hosts: str = os.environ["ALLOWED_HOSTS"]
    slack_webhook_url: str = os.environ["SLACK_WEBHOOK_URL"]


config = BaseConfig()
