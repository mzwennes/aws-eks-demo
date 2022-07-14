#!/usr/bin/env python3

from os import getenv
from flask import Flask

app = Flask(__name__)
app_version = getenv("APP_VERSION", "unknown")


@app.route("/")
def main():
    """Returns the app version"""
    return f"Welcome to ReaQta version {app_version}"


@app.route("/api")
def api():
    """Returns the API version"""
    return f"Welcome to ReaQta API version {app_version}"

if __name__ == '__main__':
    app.run(host='0.0.0.0')
