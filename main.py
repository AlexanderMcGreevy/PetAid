from petAidGemini import gemini_call
from responseToJSON import json_converter
import json

response = gemini_call()
print(response)
out_json = json_converter(response)

with open('./response_json', 'w') as f:
    json.dump(out_json, f)
    
# Installation
import googlemaps
import json
import pandas as pd
from datetime import datetime

#Inititalizing Google Maps client
API_Key = 'AIzaSyAgMO9Nlm8TcaHo5kHx2kRmbt03-8hpfAE'
gmaps = googlemaps.Client (key=API_Key)

def find_pet_clinics(location, radius=5000):
    """
    Find pet clinics near a specified location.
    
    Args:
        location: String address or (lat, lng) tuple
        radius: Search radius in meters
    
    Returns:
        DataFrame of clinic information
    """
    # If location is a string address, geocode it first
    if isinstance(location, str):
        geocode_result = gmaps.geocode(location)
        if not geocode_result:
            raise ValueError(f"Could not geocode address: {location}")
        
        lat = geocode_result[0]['geometry']['location']['lat']
        lng = geocode_result[0]['geometry']['location']['lng']
        location = (lat, lng)
    
    # Search for veterinary clinics
    places_result = gmaps.places_nearby(
        location=location,
        radius=radius,
        keyword='pet clinic veterinary',
        type='veterinary_care'
    )
    
    # Process results
    clinics = []
    for place in places_result.get('results', []):
        # Get additional details for each place
        place_details = gmaps.place(place['place_id'], fields=[
            'name', 'formatted_address', 'formatted_phone_number', 
            'opening_hours', 'rating', 'website', 'geometry'
        ])['result']
        
        # Extract hours if available
        hours = None
        if 'opening_hours' in place_details and 'weekday_text' in place_details['opening_hours']:
            hours = place_details['opening_hours']['weekday_text']
        
        clinic_info = {
            'place_id': place['place_id'],
            'name': place['name'],
            'address': place_details.get('formatted_address', 'N/A'),
            'phone': place_details.get('formatted_phone_number', 'N/A'),
            'rating': place_details.get('rating', 'N/A'),
            'website': place_details.get('website', 'N/A'),
            'hours': hours,
            'latitude': place_details['geometry']['location']['lat'],
            'longitude': place_details['geometry']['location']['lng'],
        }
        clinics.append(clinic_info)
    
    # Create DataFrame
    clinics_df = pd.DataFrame(clinics)
    return clinics_df

def get_directions(origin, destination):
    """ Get directions from origin to destination."""
    directions = gmaps.directions(
        origin,
        destination,
        mode='driving',
        departure_time=datetime.now()
    )

    if not directions:
        return None
    
    # Extract relevant direction info
    route = directions[0]['legs'][0]
    steps = []
    for step in route['steps']:
        steps.append ({
            'instruction': step['html_instructions'],
            'distance': step['distance']['text'],
            'duration': step['duration']['text'],
        })
    
    result = {
        'total_distance': route['distance']['text'],
        'total_duration': route['duration']['text'],
        'steps': steps
    }

    return result

def export_to_json(data, filename='pet_clinics.json'):
    """ Export data to JSON file for Swift app."""
    if isinstance(data, pd.DataFrame):
        data = data.to_dict(orient= 'records')

    with open (filename, 'w') as f:
        json.dump(data, f, indent=2)

    print(f"Data export to {filename}")

# Example usage
if __name__ == "__main__":
    # Find clinics near a location
    user_location = "San Francisco, CA"
    clinics = find_pet_clinics(user_location)

    # Print basic info
    print(f"Found {len(clinics)} pet clinics near {user_location}")
    print(clinics[['name', 'address', 'rating']].head())

    # Export data for Swift app
    export_to_json(clinics)

    # Get directions to the first clinic
    if not clinics.empty:
        first_clinic = clinics.iloc[0]
        directions = get_directions(
            user_location,
            f"{first_clinic['latitude']}, {first_clinic['longitude']}"
        )

        export_to_json(directions, 'directions.json')
import os
print(f"Current working directory: {os.getcwd()}")