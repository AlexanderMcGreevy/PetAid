from petAidGemini import gemini_call
from GooglePlace import get_places_data, find_pet_clinics, haversine_distance
from responseToJSON import json_converter
from flask import Flask, request, jsonify
import json

app = Flask(__name__)

def format_clinic_keys(clinic, user_lat=None, user_lng=None):
    def safe_float(value):
        try:
            return float(value)
        except:
            return 0.0

    # Compute distance if user location is provided
    distance = (
        haversine_distance(user_lat, user_lng, clinic.get("latitude", 0), clinic.get("longitude", 0))
        if user_lat is not None and user_lng is not None else 0.0
    )

    return {
        "name": clinic.get("name", ""),
        "rating": safe_float(clinic.get("rating", 0)),
        "reviewCount": clinic.get("review_count", 0),
        "distance": distance,
        "phone": clinic.get("phone", ""),
        "address": clinic.get("address", ""),
        "googleLink": clinic.get("website", "")
    }


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

    clinics_df = find_pet_clinics(location, radius)
    clinics_raw = clinics_df.to_dict(orient='records')

    # Get user's lat/lng for distance calculation
    if isinstance(location, str) and "," in location:
        user_lat, user_lng = map(float, location.split(","))
    else:
        geo = gmaps.geocode(location)[0]['geometry']['location']
        user_lat, user_lng = geo['lat'], geo['lng']

    clinics = [format_clinic_keys(c, user_lat, user_lng) for c in clinics_raw]

    print("Clinics JSON response:", json.dumps(clinics, indent=2))

    try:
        with open('./google_places_response.json', 'w') as f:
            json.dump(clinics, f, indent=2)
    except IOError as e:
        return jsonify({"error": f"Failed to write JSON file: {e}"}), 500

    return jsonify(clinics)




@app.route('/find-pet-clinics', methods=['POST'])
def find_pet_clinics_route():
    data = request.get_json()
    location = data.get('location', '')  
    radius = data.get('radius', 5000)  
    keyword = data.get('keyword', 'pet clinic')  

    places_data = get_places_data(location, radius, place_type='veterinary_care', keyword=keyword)

    try:
        with open('./pet_clinics_response.json', 'w') as f:
            json.dump(places_data, f)
    except IOError as e:
        return jsonify({"error": f"Failed to write JSON file: {e}"}), 500

    return jsonify(places_data)


if __name__ == '__main__':
    app.run(debug=True)