from flask import Flask

app = Flask(__name__)

@app.route('/health')
def health_check():
    return 'Backend OK', 200

@app.route('/api/hello')
def hello():
    return 'hello from backend'

if __name__ == "__main__":
    app.run(host="0.0.0.0", port=5005, debug=True)
