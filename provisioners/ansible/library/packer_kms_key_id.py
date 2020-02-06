"""
This module adds a KMS Key ID to Packer templates.
e.g.
Input values:
        template_dir: "../../../templates/packer/{{ platform_type }}/"
        kms_key_id: "test"

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

import glob
from ansible.module_utils.basic import AnsibleModule
from ansible.module_utils.template_utils import read_json_template
from ansible.module_utils.template_utils import write_json_template

def add_kms_key_id(module, template, kms_key_id):
    """
    Add the kms key id  to the Packer template.
    """
    # 'ami_block_device_mappings' =
    for builder in template['builders']:
        if 'ami_block_device_mappings' in builder:
            if isinstance(builder['ami_block_device_mappings'], list):
                if isinstance(builder['ami_block_device_mappings'][0], dict):
                    for ami_block_device_mapping in builder['ami_block_device_mappings']:
                        ami_block_device_mapping.update({'kms_key_id': kms_key_id})
        else:
            module.fail_json(msg="ami_block_device_mappings not found in template at builders.")
def main():
    """
    Run packer_kms_key_id custom module.
    """

    module = AnsibleModule(
        argument_spec=dict(
            template_dir=dict(required=True, type='str'),
            kms_key_id=dict(required=True, type='str')
        )
    )

    template_dir = module.params['template_dir']
    kms_key_id = module.params['kms_key_id']

    template_files = glob.glob(template_dir + "*.json")
    for template_file in template_files:
        template = read_json_template(template_file)
        add_kms_key_id(module, template, kms_key_id)
        write_json_template(template_file, template)

    module.exit_json(changed=True)

if __name__ == '__main__':
    main()
