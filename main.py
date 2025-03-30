from petAidGemini import gemini_call
from responseToJSON import json_converter
from flask import Flask, request, jsonify


app = Flask(__name__)

@app.route('/')
def index():
    return 'Welcome to the PetAid API!'

@app.route('/get-data', methods=['POST'])
def get_data():
    data = request.get_json()
    description = data.get('description', '')
    image_data = data.get('image', None) 
    return jsonify({'description': description, 'image': image_data})


@app.route('/post-data', methods=['POST'])
def post_data():
    data = request.get_json()
    description = data.get('description', '')
    image_data = data.get('image', None) 

    response = gemini_call(description, image_data)

    out_json = json_converter(response)

    return jsonify(out_json)

if __name__ == '__main__':
    app.run(debug=True)