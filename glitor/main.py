import json

import docker
import requests
from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from fastapi.middleware.trustedhost import TrustedHostMiddleware
from fastapi_utils.tasks import repeat_every

from .config import config

client = docker.from_env()

app = FastAPI(
    debug=True,
    title=config.app_name,
    description=config.app_description,
    version=config.app_version,
)

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

app.add_middleware(TrustedHostMiddleware, allowed_hosts=config.allowed_hosts)


@app.get(
    "/health",
    tags=["health"],
    summary="Health end point",
)
def health():
    return "OK"


def resource_usage(response):
    try:
        precpu_total = response["precpu_stats"]["cpu_usage"]["total_usage"]
    except:
        precpu_total = 0

    try:
        precpu_system = response["precpu_stats"]["system_cpu_usage"]
    except:
        precpu_system = 0

    try:
        system_cpu_usage = response["cpu_stats"]["system_cpu_usage"]
    except:
        system_cpu_usage = 0

    try:
        cpu_total_usage = response["cpu_stats"]["cpu_usage"]["total_usage"]
    except:
        cpu_total_usage = 0

    try:
        online_cpus = response["cpu_stats"]["online_cpus"]
    except:
        online_cpus = 0

    try:
        memory_stats_usage = response["memory_stats"]["usage"]
    except:
        memory_stats_usage = 0

    try:
        memory_stats_cache = response["memory_stats"]["stats"]["cache"]
    except:
        memory_stats_cache = 0

    try:
        memory_stats_limit = response["memory_stats"]["limit"]
    except:
        memory_stats_limit = 0

    cpu_delta = cpu_total_usage - precpu_total
    system_delta = system_cpu_usage - precpu_system
    cpu_usage = cpu_delta / system_delta * online_cpus * 100 if system_delta != 0 else 0

    memory_usage = memory_stats_usage - memory_stats_cache
    memory_usage = (
        memory_usage / memory_stats_limit * 100 if memory_stats_limit != 0 else 0
    )

    return cpu_usage, memory_usage


def send_message_to_slack(container_name, container_status, cpu_usage, memory_usage):
    hook = config.slack_webhook_url
    headers = {"content-type": "application/json"}

    COLOR = "#FF0000"
    TITLE = f"[Usage Alert] | {container_name} | {container_status}"
    MESSAGE = f"CPU Usage: {cpu_usage} % | Total Memory Usage: {memory_usage} %"
    payload = {
        "attachments": [
            {
                "fallback": "",
                "pretext": "",
                "color": COLOR,
                "fields": [{"title": TITLE, "value": MESSAGE, "short": False}],
            }
        ]
    }
    r = requests.post(hook, data=json.dumps(payload), headers=headers)
    print("Response: " + str(r.status_code) + "," + str(r.reason))


exited_containers = set()


@app.on_event("startup")
@repeat_every(seconds=60, raise_exceptions=True)
def resource_usage_alert():
    total_memory_usage = 0
    for container in client.containers.list(all=True):
        stats_json = container.stats(stream=False)
        res_usage = resource_usage(stats_json)
        cpu_usage = round(res_usage[0], 2)
        memory_usage = round(res_usage[1], 2)
        total_memory_usage = total_memory_usage + memory_usage
        if (
            cpu_usage > config.cpu_threshold
            or total_memory_usage > config.memory_threshold
            or (
                container.status != "running"
                and container.short_id not in exited_containers
            )
        ):
            send_message_to_slack(
                container.name,
                container.status,
                cpu_usage,
                round(total_memory_usage, 2),
            )
        if (
            container.status != "running"
            and container.short_id not in exited_containers
        ):
            exited_containers.add(container.short_id)
