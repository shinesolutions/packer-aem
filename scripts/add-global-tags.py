#!/usr/bin/env python

import sys, ruamel.yaml, json, glob

# Usage validation
if len(sys.argv) != 3:
    print('Usage: add-global-tags.py <template_dir> <global_tags_conf>')
    sys.exit(1)


def read_template(file_name):
    file = open(file_name, 'r')
    template = json.load(file)
    file.close()
    return template


def write_template(file_name, template):
    file = open(file_name, 'w')
    json.dump(template, file, indent=2)
    file.close()


def read_global_tags(file_name):
    file = open(file_name, 'r')
    tags = ruamel.yaml.load(file, Loader=ruamel.yaml.SafeLoader)
    file.close()

    return [(entry['Key'], entry['Value']) for entry in tags['Tags']]


def add_tags(global_tags, template, tag_key):
    template['builders'][0][tag_key].update(global_tags)


template_dir = sys.argv[1]
tags_file_name = sys.argv[2]
tag_keys = ['run_tags', 'run_volume_tags', 'snapshot_tags', 'tags']

global_tags = read_global_tags(tags_file_name)
template_files = glob.glob(template_dir + "*.json")
for template_file in template_files:
    template = read_template(template_file)
    for tag_key in tag_keys:
        if tag_key in template['builders'][0]:
            add_tags(global_tags, template, tag_key)
    write_template(template_file, template)
