const express = require("express");

const app = express();
const PORT = 3000;

app.get("/", (req, res) => {
  res.json({
    application: "Express Frontend",
    status: "running",
    message: "Dockerized Express application running on ECS Fargate"
  });
});

app.get("/health", (req, res) => {
  res.json({
    status: "healthy",
    application: "Express Frontend"
  });
});

app.listen(PORT, "0.0.0.0", () => {
  console.log(`Express application running on port ${PORT}`);
});
