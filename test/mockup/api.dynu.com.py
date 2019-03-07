from flask import Flask, jsonify

app = Flask(__name__)

#
#  /dominio --> file contenente dei record
#  ad ogni dominio e'  collegato ad un file
#  il file avra' una intestazione (SOA)
#  una record sara' una riga con commento che definisce l'ID
#  una riga puo' essere commmentata

#  hostname IN A   192.168.1.2  ##id:1,location:
#  nodo34   IN A   192.168.2.2  ##id:2,location:taramelli
#  servizio IN TXT "key=value"  ##id:3,location:mezzocorona
#  ; nodo5  IN A   192.168.2.3  ##id:4,location:
#
#
#


@app.route('/v1.0/oauth2/token', methods=['GET'])
def get_tasks():
    return jsonify({'tasks': tasks})

@app.route('/nic/update', methods=['GET'])
def get_tasks():
    return jsonify({'tasks': tasks})

@app.route('/v1.0/ping', methods=['GET'])
def get_tasks():
    return jsonify({'tasks': tasks})

@app.route('/v1.0/dns/records/', methods=['GET'])
def get_tasks():
    return jsonify({'tasks': tasks})

@app.route('/v1.0/dns/record/enable/', methods=['GET'])
def get_tasks():
    return jsonify({'tasks': tasks})

@app.route('/v1.0/dns/record/disable/', methods=['GET'])
def get_tasks():
    return jsonify({'tasks': tasks})

@app.route('/v1.0/dns/record/delete/', methods=['GET'])
def get_tasks():
    return jsonify({'tasks': tasks})

@app.route('/v1.0/dns/record/add', methods=['POST'])
def get_tasks():
    return jsonify({'tasks': tasks})



if __name__ == '__main__':
    app.run(debug=True)
