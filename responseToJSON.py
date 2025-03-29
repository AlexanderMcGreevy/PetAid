
def json_converter(response):
    resp_sects = response.split('\n')

    # Initial format
    output_json = {
        "possible_issue": '',
        "likelihood": '',
        "severity": '',
        "explanation": '',
        "recommendation": ''
    }

    for section in resp_sects:
        if section == '':
            continue

        # Enter info into JSON
        match section[:3].lower():
            case "pos":
                output_json['possible_issue'] = section[16:]
            case "lik":
                output_json['likelihood'] = section[12:]
            case "sev":
                output_json['severity'] = section[10:]
            case "exp":
                output_json['explanation'] = section[13:]
            case "rec":
                output_json['recommendation'] = section[16:]

    return output_json