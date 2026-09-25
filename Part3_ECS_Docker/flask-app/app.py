from flask import Flask, jsonify

app = Flask(__name__)

def home_response():
    return jsonify({
        "application": "Flask Backend",
        "status": "running",
        "message": "Dockerized Flask application running on ECS Fargate"
    })

def health_response():
    return jsonify({
        "status": "healthy",
        "application": "Flask Backend"
    })

@app.route("/")
def home():
    return home_response()

@app.route("/api")
@app.route("/api/")
def api_home():
    return home_response()

@app.route("/health")
def health():
    return health_response()

@app.route("/api/health")
def api_health():
    return health_response()

if __name__ == "__main__":
    app.run(host="0.0.0.0", port=5000)
