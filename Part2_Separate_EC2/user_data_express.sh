#!/bin/bash

set -e

apt-get update
apt-get install -y nodejs npm

mkdir -p /opt/express-app
cd /opt/express-app

cat > package.json <<'JSONEOF'
{
  "name": "terraform-part2-express",
  "version": "1.0.0",
  "description": "Express frontend for Terraform Part 2",
  "main": "app.js",
  "scripts": {
    "start": "node app.js"
  },
  "dependencies": {
    "express": "^5.1.0"
  }
}
JSONEOF

npm install

cat > app.js <<'JSEOF'
const express = require("express");

const app = express();
const PORT = 3000;
const FLASK_URL = process.env.FLASK_URL;

app.get("/", (req, res) => {
  res.json({
    application: "Express Frontend",
    status: "running",
    message: "Express frontend deployed on a separate EC2 using Terraform"
  });
});

app.get("/health", (req, res) => {
  res.json({
    status: "healthy"
  });
});

app.get("/flask-health", async (req, res) => {
  try {
    const response = await fetch(FLASK_URL + "/health");
    const data = await response.json();

    res.json({
      express_status: "healthy",
      flask_status: data.status,
      communication: "Express EC2 successfully reached Flask EC2"
    });
  } catch (error) {
    res.status(500).json({
      express_status: "healthy",
      flask_status: "unreachable",
      error: error.message
    });
  }
});

app.listen(PORT, "0.0.0.0", () => {
  console.log(`Express application running on port $${PORT}`);
  console.log(`Flask backend URL: $${FLASK_URL}`);
});
JSEOF

cat > /etc/systemd/system/express-app.service <<SERVICEEOF
[Unit]
Description=Terraform Part 2 Express Application
After=network.target

[Service]
WorkingDirectory=/opt/express-app
Environment="FLASK_URL=http://${flask_private_ip}:5000"
ExecStart=/usr/bin/node /opt/express-app/app.js
Restart=always
User=root

[Install]
WantedBy=multi-user.target
SERVICEEOF

systemctl daemon-reload
systemctl enable express-app
systemctl start express-app
