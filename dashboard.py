import datetime
import logging
import shlex
import subprocess

import toml
from expiringdict import ExpiringDict
from fastapi import FastAPI, Request
from fastapi.responses import HTMLResponse, PlainTextResponse
from fastapi.staticfiles import StaticFiles
from fastapi.templating import Jinja2Templates

logger = logging.getLogger("uvicorn.dashboard")

app = FastAPI()
app.mount("/static", StaticFiles(directory="static"), name="static")
conf = toml.load("./config.toml")
template = Jinja2Templates("./template/")

logger.info("Config: %s", conf)


class Batch:
    """Batch Jobs and its Cache"""

    cache = ExpiringDict(
        max_len=100, max_age_seconds=datetime.timedelta(hours=1).seconds
    )

    @classmethod
    def get(cls, name: str):
        """Returns Jobs Result"""
        if name in cls.cache:
            return cls.cache[name]
        return cls.post(name)

    @classmethod
    def post(cls, name: str):
        """Refreshing Jobs Cache"""
        job = conf.get("job", {}).get(name, None)
        if job is None:
            return {}
        proc = subprocess.run(shlex.split(job["command"]), capture_output=True)
        result = proc.stdout.decode()

        cls.cache[name] = result
        return result


@app.get("/job/{name}", response_class=PlainTextResponse)
async def get_job(name: str):
    """GET Job using cache

    Re-Run if cache is empty.
    """
    return Batch.get(name)


@app.post("/job/{name}", response_class=PlainTextResponse)
async def get_post(name: str):
    """Re-Run & Get Job using cache"""
    return Batch.post(name)


@app.get("/", response_class=HTMLResponse)
async def get(request: Request):
    """Index Page"""
    context = {"request": request, "names": conf["batch"]["jobs"]}
    return template.TemplateResponse("index.html", context)
