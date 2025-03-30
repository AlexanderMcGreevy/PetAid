from petAidGemini import gemini_call
from responseToJSON import json_converter
from flask import Flask, request, jsonify


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

if __name__ == '__main__':
    app.run(debug=True)