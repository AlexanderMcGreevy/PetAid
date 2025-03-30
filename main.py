from petAidGemini import gemini_call
from responseToJSON import json_converter
import json
from flask import Flask, request, jsonify
import base64
import os

app = Flask('https://petaidcloud.onrender.com/')

@app.route('/diagnose', methods=['POST'])
def diagnose():
    data = request.get_json()
    description = data.get('description', '')
    image_data = data.get('image', None) 

    response = gemini_call(description, image_data)
    print(response)

    out_json = json_converter(response)

    with open('./response_json', 'w') as f:
        json.dump(out_json, f) 

    return out_json

# Call diagnose
diagnose()