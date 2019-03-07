#!flask/bin/python
from flask import Flask

from flask import request
from flask import jsonify

app = Flask(__name__)

@app.route("/", methods=["GET"])
def get_my_ip():
    if request.headers.getlist("X-Forwarded-For"):
        ip = request.headers.getlist("X-Forwarded-For")[0]
    else:
        ip = request.remote_addr
    return jsonify({'ip': ip}), 200


if __name__ == '__main__':
    app.run(debug=True,port=6000)
