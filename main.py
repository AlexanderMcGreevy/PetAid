from petAidGemini import gemini_call
from GooglePlace import get_places_data, find_pet_clinics
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
    radius = data.get('radius', 1000)

    if not location:
        location = "New York, NY"  # fallback for testing

    # Use the smart version
    clinics_df = find_pet_clinics(location, radius)

    # Convert dataframe to list of dictionaries
    clinics = clinics_df.to_dict(orient='records')

    # Optional: Save to JSON file
    try:
        with open('./google_places_response.json', 'w') as f:
            json.dump(clinics, f, indent=2)
    except IOError as e:
        return jsonify({"error": f"Failed to write JSON file: {e}"}), 500

    return jsonify(clinics)

@app.route('/find-pet-clinics', methods=['POST'])
def find_pet_clinics():
    data = request.get_json()
    location = data.get('location', '')  # Latitude and longitude (e.g., "37.7749,-122.4194")
    radius = data.get('radius', 5000)  # Search radius in meters (default: 5000 meters)
    keyword = data.get('keyword', 'pet clinic')  # Optional keyword for refining search

    # Call the function from GooglePlace.py
    places_data = get_places_data(location, radius, place_type='veterinary_care', keyword=keyword)

    # Save the response to a JSON file
    try:
        with open('./pet_clinics_response.json', 'w') as f:
            json.dump(places_data, f)
    except IOError as e:
        return jsonify({"error": f"Failed to write JSON file: {e}"}), 500

    return jsonify(places_data)
if __name__ == '__main__':
    app.run(debug=True)