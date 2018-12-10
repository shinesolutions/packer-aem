"""
Add tags (set in `aws.tags` configuration) to Packer template files.
This will modify the Packer template files' properties described in `tag_keys`,
this workaround is needed due to Packer's lack of built-in support for
injecting additional tags. Passing vars one by one isn't an option because we
wouldn't know in advance how many additional vars need to be declared.
"""

#!/usr/bin/python

import json
import glob
from ansible.module_utils.basic import AnsibleModule


def read_template(file_name):
    """
    Read the original Packer template files from filesystem.
    """
    file_read = open(file_name, 'r')
    template = json.load(file_read)
    file_read.close()
    return template


def write_template(file_name, template):
    """
    Write the Packer template files decorated with the additional tags.
    """
    file_write = open(file_name, 'w')
    json.dump(template, file_write, indent=2)
    file_write.close()


def add_tags(tags, template, tag_key):
    """
    Add the tags to the Packer template.
    """
    for tag in tags:
        for builder in template['builders']:
            builder[tag_key].update({tag['Key']: tag['Value']})


def main():
    """
    Run packer_tags custom module.
    """

    module = AnsibleModule(
        argument_spec=dict(
            template_dir=dict(required=True, type='str'),
            tags=dict(required=True, type='list'),
        )
    )

    template_dir = module.params['template_dir']
    tags = module.params['tags']
    tag_keys = ['run_tags', 'run_volume_tags', 'snapshot_tags', 'tags']

    template_files = glob.glob(template_dir + "*.json")
    for template_file in template_files:
        template = read_template(template_file)
        for tag_key in tag_keys:
            if tag_key in template['builders'][0]:
                add_tags(tags, template, tag_key)
        write_template(template_file, template)

    module.exit_json(changed=True)

if __name__ == '__main__':
    main()
