import json
import re

if __name__ == '__main__':
    # columns_dict, dict with dict with features and descriptions
    with open("columns_description.txt", "r") as file:
        lines = file.readlines()

    columns_dict = {}
    for line in lines:
        if ": " in line:  # Ensure the line contains a key-value separator
            key, value = line.strip().split(": ", 1)
            columns_dict[key] = value

    with open("columns_dict.json", "w") as json_file:
        json.dump(columns_dict, json_file, indent=4)

    # feature_dict, dict with features, descriptions, values
    structured_data = defaultdict(lambda: {"desc": "", "values": {}})

    with open("data_description.txt", "r") as file:
        lines = file.readlines()

    current_feature = None

    for line in lines:
        # Match feature description
        feature_match = re.match(r"(\w+):\s+(.+)", line)
        if feature_match:
            current_feature = feature_match.group(1)
            structured_data[current_feature]["desc"] = feature_match.group(2)
        elif current_feature:
            # Match key-value pairs (e.g., "20 1-STORY 1946 & NEWER ALL STYLES")
            value_match = re.match(r"^\s*(\S+)\s+(.+)", line)
            if value_match:
                key = value_match.group(1)
                value = value_match.group(2)
                structured_data[current_feature]["values"][key] = value

    structured_data = dict(structured_data)

    with open("feature_dict.json", "w") as json_file:
        json.dump(structured_data, json_file, indent=4)