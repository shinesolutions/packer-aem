"""
This module updates any keys in the packer template which are in 'builders'.
e.g.
Input values:
        template_dir: "../../../templates/packer/{{ platform_type }}/"
        packer_key: ami_block_device_mappings
        add_key: "kms_key_id"
        add_value: "test"

This will update the Key 'kms_key_id' in the packer template
{
    Builders: [
        ami_block_device_mappings: [
            {
            kms_key_id: test

            }

        ]
    ]
}

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

def add_key_to_builders(module, template, packer_key, add_key, add_value):
    """
    Add the Key and vlaue to the Packer template.
    """
    for builder in template['builders']:
        if packer_key in builder:
            if isinstance(builder[packer_key], dict):
                builder[packer_key].update({add_key: add_value})
            elif isinstance(builder[packer_key], list):
                if isinstance(builder[packer_key][0], dict):
                    for packer_keys in builder[packer_key]:
                        packer_keys.update({add_key: add_value})
                else:
                    builder[packer_key].append({add_key: add_value})
            else:
                builder.update({add_key: add_value})
        else:
            module.fail_json(msg="Provided packer_key \"" + packer_key + "\" not found in template at builders.")
def main():
    """
    Run packer_tags custom module.
    """

    module = AnsibleModule(
        argument_spec=dict(
            template_dir=dict(required=True, type='str'),
            packer_key=dict(required=True, type='str'),
            add_key=dict(required=True, type='str'),
            add_value=dict(required=True, type='str')
        )
    )

    template_dir = module.params['template_dir']
    packer_key = module.params['packer_key']
    add_key = module.params['add_key']
    add_value = module.params['add_value']

    template_files = glob.glob(template_dir + "*.json")
    for template_file in template_files:
        template = read_template(template_file)
        add_key_to_builders(module, template, packer_key, add_key, add_value)
        write_template(template_file, template)

    module.exit_json(changed=True)

if __name__ == '__main__':
    main()
