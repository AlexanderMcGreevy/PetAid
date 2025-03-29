#Values in variables are placeholders

from google import genai
from dotenv import load_dotenv
import os

load_dotenv(".env")
print(os.getenv("GEMINI_API_KEY"))
client = genai.Client(api_key=f"{os.getenv("GEMINI_API_KEY")}")




#Only dogs have breeds (so far)

species='dog'
breed='poodle'
weight='normal'
name='fido'
age=6

pet_information={
    'species':species,
    'weight_kg':5,
    'name' : name,
    'age_years' : age
}

if species=='dog':
    pet_information['breed']=breed

pet_health_question = input('Please put your question: ')

pet_health_question = 'pet health question: ' + pet_health_question

pet_information_list=[]

for key in pet_information:
    pet_information_list+= [key + ' = ' + str(pet_information[key]) + ' ']

response_info = "Phrase it in this template, don't say anything along the lines of (okay, here's the analysis) : Possible issue: Issue, description\nLikelyhood: likelyhood percent\nSeverity: severity\nExplanation: Description of problem, possible causes\nRecommendation: Seek a vet or don't seek a vet?"


response = client.models.generate_content(
    model="gemini-2.0-flash", contents=[pet_information_list,response_info,pet_health_question, 'You are an a digital assistant for vetarinary affairs. Given the information and question, make a suggestion on what the issue is. Make a percent likelihood and severity. If likelyhood is below 15 percent, do not add to final report. Do not add anything about treatment, only if you should see a vet.', 'Phrase in neutral tone, though not too clinical.']
)
print(response.text)
