from petAidGemini import gemini_call
from responseToJSON import json_converter
import json

response = gemini_call()
print(response)
out_json = json_converter(response)

with open('./response_json', 'w') as f:
    json.dump(out_json, f)