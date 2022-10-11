import requests
import json

url = 'http://0.0.0.0:5000/api/'

data = [[3, 1, 6, 5,
        6, 3, 9, 4,
        1, 3, 1]]
j_data = json.dumps(data)
headers = {"content-type: application/json", "Accept-Charset: UTF-8"}
r = requests.get(url, data=j_data, headers=headers)
print(r, r.text)