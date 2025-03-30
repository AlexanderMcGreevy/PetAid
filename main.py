from petAidGemini import gemini_call
from responseToJSON import json_converter
from GooglePlace import get_places_data
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

@app.route('/googleplaces', methods=['POST'])
def google_places():
    data = request.get_json()
    location = data.get('location', '')
    radius = data.get('radius', 1000)  # Default radius in meters

    # Call the function from googleplace.py
    places_data = get_places_data(location, radius)

    # Save the response to a JSON file
    try:
        with open('./google_places_response.json', 'w') as f:
            json.dump(places_data, f)
    except IOError as e:
        return jsonify({"error": f"Failed to write JSON file: {e}"}), 500
    return jsonify(places_data)
if __name__ == '__main__':
    app.run(debug=True)
