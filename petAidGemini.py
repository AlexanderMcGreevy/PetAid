#Values in variables are placeholders
from google import genai
from google.genai import types
from dotenv import load_dotenv
import os
import requests

load_dotenv(".env")

def gemini_call(desc='', image='', extra_info=[]):
    client = genai.Client(api_key=os.getenv("GEMINI_API_KEY"))
    #Only dogs have breeds (so far)
    # species='dog'
    # breed='poodle'
    # weight='normal'
    # name='fido'
    # age=6
    # pet_information={
    #     'species':species,
        
    #     'weight_kg':5,
    #     'name' : name,
    #     'age_years' : age
    # }

    # if species=='dog':
    #     pet_information['breed']=breed

    # pet_health_question = "My poor dog has been limping the past few days. He won't put his front right leg down when he is walking" #input("Type in your question here: ")

    # has_image = "no" #input("Do you want to submit an image? Please type 'Yes' or 'No': ")
    # has_image = has_image.lower()

    # image_input = None
    # if has_image == "yes":
    #     image_input = input("Add an image link here: ")
    #     image_input = requests.get(image_input)

    # pet_information_list=[]

    # for key in pet_information:
    #     pet_information_list+= [key + ' = ' + str(pet_information[key]) + ' ']

    prompt_starter = """You are a vetarinary affairs assistant gleefully looking to help pet owners in need. They will give you information on their pets' ailments, 
    so you must attempt to identify the issue. Please format your response using the following template (Remove brackets from your responses):\n
    Possible issue: [Issue with description]\n
    Likelihood: [Percent Likelihood]\n
    Severity: [Severity]\n
    Explanation: [Explanation of problem and possible causes]\n
    Recommendation: [Recommendation for help]\n\n

    If likelyhood is below 15 percent, replace the percent with the message "Highly Unlikely". DO NOT promote any methods for the owner to treat their pet, only
    recommend if they should see a vet. Phrase in neutral tone and avoid clinical jargon that the layperson would not know when possible.\n\n

    Pet Owner Question:\n
    """

    prompt = prompt_starter + '\n\n' + desc + '\nAdditional Information:'

    for key in extra_info:
        if extra_info[key] == '':
            extra_info[key] = 'N/A'
        
        prompt += f"\n{key}: {extra_info[key]}"

    prompt = [prompt]

    if image is not None:
        prompt += [image]

    response = client.models.generate_content(
        model="gemini-2.0-flash", 
        contents=prompt
    )

    return response.text
