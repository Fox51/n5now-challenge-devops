from flask import Flask, jsonify
import os

app = Flask(__name__)

@app.route('/environment', methods=['GET'])
def get_environment():
    environment = os.getenv('DEPLOYMENT_ENV', 'Unknown')
    return jsonify(environment=environment)

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000)
