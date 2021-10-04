import os
from datetime import datetime

from flask import Flask, jsonify, request

app = Flask(__name__)


@app.route("/api/cache-me")
def cache():
    return "nginx will cache this response"


@app.route("/api/info")
def info():

    resp = {
        "connecting_ip": request.headers["X-Real-IP"],
        "proxy_ip": request.headers["X-Forwarded-For"],
        "host": request.headers["Host"],
        "user-agent": request.headers["User-Agent"],
        "backend-hostname": os.environ["HOSTNAME"],
        "timestamp": datetime.now().isoformat(),
        "environment": os.environ["ENVIRONMENT"],
    }

    return jsonify(resp)


@app.route("/api/health-check")
def healthcheck():
    return "success"
