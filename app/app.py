from flask import Flask, render_template
import requests

app = Flask(__name__)

# Backend service URL - using CoreDNS service discovery
BACKEND_SERVICE_URL = 'http://backend-service.backend.svc.cluster.local'

@app.route('/health')
def health_check():
    return 'OK', 200

@app.route('/')
def home():
    """Call backend service via CoreDNS"""
    try:
        response = requests.get(f'{BACKEND_SERVICE_URL}/api/hello', timeout=5)
        backend_message = response.text
    except requests.exceptions.RequestException as e:
        backend_message = f"Failed to call backend: {str(e)}"
    
    return render_template('home.html', backend_response=backend_message)

if __name__ == "__main__":
    app.run(host="0.0.0.0", port=5000)
