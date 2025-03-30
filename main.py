from petAidGemini import gemini_call
from GooglePlace import get_places_data
from responseToJSON import json_converter
from flask import Flask, request, jsonify
import json

app = Flask(__name__)

@app.route('/get-data', methods=['POST'])
def get_data():
    data = request.get_json()
    description = data.get('description', '')
    image_data = data.get('image', None) 
    last_vet_visit = data.get('lastVetVisit', '')
    past_illnesses = data.get('pastIllnesses', '')
    name = data.get('name', '')
    age = data.get('age', '')
    species = data.get('species', '')
    breed = data.get('breed', '')
    return jsonify({'description': description, 'image': image_data, 'lastVetVisit': last_vet_visit, 'pastIllnesses': past_illnesses, 'name': name, 'age': age, 'species': species, 'breed': breed})


@app.route('/post-data', methods=['POST'])
def post_data():
    data = request.get_json()
    description = data.get('description', '')
    image_data = data.get('image', None)
    last_vet_visit = data.get('lastVetVisit', '')
    past_illnesses = data.get('pastIllnesses', '')
    name = data.get('name', '')
    age = data.get('age', '')
    species = data.get('species', '')
    breed = data.get('breed', '')

    extra_info = {'Last Vet Visit': last_vet_visit, 'Past Illnesses': past_illnesses, 'Name': name, 'Age': age, 'Species': species, 'Breed': breed}
    response = gemini_call(description, image_data, extra_info)

    out_json = json_converter(response)

    return jsonify(out_json)

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