#!/bin/bash

set -e

apt-get update
apt-get install -y python3 python3-pip python3-venv

mkdir -p /opt/flask-app
cd /opt/flask-app

python3 -m venv venv

cat > app.py <<'PYEOF'
from flask import Flask, jsonify

app = Flask(__name__)

@app.route("/")
def home():
    return jsonify({
        "application": "Flask Backend",
        "status": "running",
        "message": "Flask backend deployed on a separate EC2 using Terraform"
    })

@app.route("/health")
def health():
    return jsonify({"status": "healthy"})

if __name__ == "__main__":
    app.run(host="0.0.0.0", port=5000)
PYEOF

/opt/flask-app/venv/bin/pip install flask

cat > /etc/systemd/system/flask-app.service <<'SERVICEEOF'
[Unit]
Description=Terraform Part 2 Flask Application
After=network.target

[Service]
WorkingDirectory=/opt/flask-app
ExecStart=/opt/flask-app/venv/bin/python /opt/flask-app/app.py
Restart=always
User=root

[Install]
WantedBy=multi-user.target
SERVICEEOF

systemctl daemon-reload
systemctl enable flask-app
systemctl start flask-app
