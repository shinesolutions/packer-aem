"""
Utility for reading and writing JSON templates.
"""
import json

def read_json_template(file_name):
    """
    Read the original JSON template files from filesystem.
    """
    file_read = open(file_name, 'r')
    template = json.load(file_read)
    file_read.close()
    return template

def write_json_template(file_name, template):
    """
    Write the decorated JSON template files.
    """
    file_write = open(file_name, 'w')
    json.dump(template, file_write, indent=2)
    file_write.close()
