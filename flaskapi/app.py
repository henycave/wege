
# import re
# from flask import Flask, request, redirect, url_for, flash, jsonify
# import numpy as np
# import pickle as p
# import json

# app = Flask(__name__)

# modelfile = 'models/final_prediction.pkl'
# model = p.load(open(modelfile, 'rb'))

# @app.route('/predict/', methods=['POST'])

# def predict():
#     event = json.loads(request.data)
#     values = event['values']
#     values = list(map(np.float, values))
#     pre = np.array(values)
#     pre = pre.reshape(1,-1)
#     # res = model.get_dollar_estimate(5,20,True,True)
#     res = model.predict(pre)
    
#     print(res)
#     return str(res[0])

# if __name__ == '__main__':
#     app.run(debug=True)


from crypt import methods
from optparse import Values
import re
from flask import Flask, request, redirect, url_for, flash, jsonify
import numpy as np
import pickle as p
import json
from sklearn.feature_extraction.text import CountVectorizer

app = Flask(__name__)

vectorfile = 'models/vector.pkl'
classifierfile = 'models/classifier.pkl'
model = p.load(open(classifierfile, 'rb'))
vector = p.load(open(vectorfile, 'rb'))

@app.route("/", methods=["GET"])
def index():
    return "<h1> Hello worlds </h1>"

@app.route('/predict/', methods=['POST'])

def predict():
    event = json.loads(request.data)
    values = event['values']
   # values = list(map(np.string_, values))
    pre = vector.transform(values)
    # pre = np.array(values)
    res = model.predict(pre)

    # res = model.get_dollar_estimate(5,20,True,True)
    #res = model.predict(pre)
    
    print(res)
    return str(res)

if __name__ == '__main__':
    app.run(debug=True, host='0.0.0.0')

