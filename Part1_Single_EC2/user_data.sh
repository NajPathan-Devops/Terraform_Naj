#!/bin/bash
set -e

exec > >(tee /var/log/user-data.log | logger -t user-data -s 2>/dev/console) 2>&1

apt-get update -y
apt-get upgrade -y

apt-get install -y python3 python3-pip python3-venv nodejs npm git curl

mkdir -p /opt/flask-app
mkdir -p /opt/express-app

# Flask application
cat > /opt/flask-app/app.py <<'PYEOF'
from flask import Flask, jsonify

app = Flask(__name__)

@app.route("/")
def home():
    return jsonify({
        "application": "Flask Backend",
        "status": "running",
        "message": "Flask backend deployed using Terraform"
    })

@app.route("/health")
def health():
    return jsonify({"status": "healthy"})

if __name__ == "__main__":
    app.run(host="0.0.0.0", port=5000)
PYEOF

python3 -m venv /opt/flask-app/venv
/opt/flask-app/venv/bin/pip install --upgrade pip
/opt/flask-app/venv/bin/pip install flask

# Express application
cat > /opt/express-app/package.json <<'JSONEOF'
{
  "name": "terraform-express-app",
  "version": "1.0.0",
  "main": "server.js",
  "scripts": {
    "start": "node server.js"
  },
  "dependencies": {
    "express": "^5.1.0"
  }
}
JSONEOF

cat > /opt/express-app/server.js <<'JSEOF'
const express = require("express");

const app = express();
const PORT = 3000;

app.get("/", (req, res) => {
  res.json({
    application: "Express Frontend",
    status: "running",
    message: "Express frontend deployed using Terraform"
  });
});

app.get("/health", (req, res) => {
  res.json({ status: "healthy" });
});

app.listen(PORT, "0.0.0.0", () => {
  console.log(`Express application running on port ${PORT}`);
});
JSEOF

cd /opt/express-app
npm install

# Create systemd service for Flask
cat > /etc/systemd/system/flask-app.service <<'SERVICEEOF'
[Unit]
Description=Terraform Flask Application
After=network.target

[Service]
WorkingDirectory=/opt/flask-app
ExecStart=/opt/flask-app/venv/bin/python /opt/flask-app/app.py
Restart=always
User=root

[Install]
WantedBy=multi-user.target
SERVICEEOF

# Create systemd service for Express
cat > /etc/systemd/system/express-app.service <<'SERVICEEOF'
[Unit]
Description=Terraform Express Application
After=network.target

[Service]
WorkingDirectory=/opt/express-app
ExecStart=/usr/bin/node /opt/express-app/server.js
Restart=always
User=root

[Install]
WantedBy=multi-user.target
SERVICEEOF

systemctl daemon-reload
systemctl enable flask-app
systemctl enable express-app
systemctl start flask-app
systemctl start express-app

echo "Flask and Express applications started successfully."
