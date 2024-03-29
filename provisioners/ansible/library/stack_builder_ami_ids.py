"""
This module generates a YAML AEM AWS Stack Builder config file which contains the AMI IDs for all components.
The AMI IDs are filtered based on AEM Profile and OS Type.
The YAML file is designed to be dropped directly in AEM AWS Stack Builder configuration path.
"""
#!/usr/bin/python3

import sys
import boto3
import yaml
from dateutil.parser import parse as parse_dt
from ansible.module_utils.basic import AnsibleModule

def get_most_recent_ami_id(ec2, application_name, criteria):
    """
    Given a set of criteria, retrieve the latest AMI ID from AWS using EC2 service.
    """

    application_role = criteria['application_role']
    application_profile = criteria['application_profile']
    os_type = criteria['os_type']
    version = criteria['version']
    jdk_version = criteria['jdk_version']

    filters = [
        {
            'Name': 'tag:Application Role',
            'Values': [application_role]
        },
        {
            'Name': 'tag:Application Profile',
            'Values': [application_profile]
        },
        {
            'Name': 'tag:OS Type',
            'Values': [os_type]
        },
        {
            'Name': 'tag:jdk_version',
            'Values': [jdk_version]
        },
        {
            'Name': 'tag:Version',
            'Values': [version]
        },
    ]

    most_recent_image = None
    for image in ec2.images.filter(Filters=filters):
        if most_recent_image is None:
            most_recent_image = image
            continue
        if parse_dt(image.creation_date) > parse_dt(most_recent_image.creation_date):
            most_recent_image = image

    if most_recent_image is not None:
        sys.stderr.write('{0}: {1.id}{2}'.format(application_name, most_recent_image, '\n'))
        most_recent_ami_id = '{0.id}'.format(most_recent_image)
    else:
        most_recent_ami_id = None

    return most_recent_ami_id

def write_file(out_file_name, ami_ids, aem_profile, os_type, jdk_type):
    """
    Create an AEM AWS Stack Builder config file containing the latest AMI IDs.
    """

    out_file = open(out_file_name, 'w')
    out_file.write('---\n')
    out_file.write('# Generated by Packer AEM\n')
    out_file.write('# AMI IDs for AEM profile {0} on OS type {1} with Java version {2}\n'.format(aem_profile, os_type, jdk_type))

    yaml.dump({
        'ami_ids': ami_ids
    }, out_file, default_flow_style=False)

    out_file.close()

def main():
    """
    Run stack_builder_ami_ids custom module.
    """

    module = AnsibleModule(
        argument_spec=dict(
            aem_profile=dict(required=True, type='str'),
            os_type=dict(required=True, type='str'),
            jdk_type=dict(required=True, type='str'),
            version=dict(required=True, type='str'),
            out_file=dict(required=True, type='str'),
            region=dict(required=True, type='str'),
        )
    )

    aem_profile = module.params['aem_profile']
    os_type = module.params['os_type']
    jdk_type = module.params['jdk_type']
    jdk_version = jdk_type[3:]
    version = '*' if not module.params['version'] else module.params['version']
    out_file = module.params['out_file']
    region = module.params['region']

    ec2 = boto3.resource('ec2', region_name=region)

    author_dispatcher_criteria = {'application_role': 'dispatcher AMI', 'application_profile': aem_profile, 'os_type': os_type, 'version': version, 'jdk_version': jdk_version}
    publish_dispatcher_criteria = {'application_role': 'dispatcher AMI', 'application_profile': aem_profile, 'os_type': os_type, 'version': version, 'jdk_version': jdk_version}
    publish_criteria = {'application_role': 'publish AMI', 'application_profile': aem_profile, 'os_type': os_type, 'version': version, 'jdk_version': jdk_version}
    author_criteria = {'application_role': 'author AMI', 'application_profile': aem_profile, 'os_type': os_type, 'version': version, 'jdk_version': jdk_version}
    author_publish_disp_criteria = {'application_role': 'author-publish-dispatcher AMI', 'application_profile': aem_profile, 'os_type': os_type, 'version': version, 'jdk_version': jdk_version}
    # NOTE: chaos_monkey and orchestrator components only support JDK8 for now
    orchestrator_criteria = {'application_role': 'java AMI', 'application_profile': aem_profile, 'os_type': os_type, 'version': version, 'jdk_version': '8'}
    chaos_monkey_criteria = {'application_role': 'java AMI', 'application_profile': aem_profile, 'os_type': os_type, 'version': version, 'jdk_version': '8'}

    ami_ids = {
        'author_dispatcher': get_most_recent_ami_id(ec2, 'Dispatcher AMI', author_dispatcher_criteria),
        'publish_dispatcher': get_most_recent_ami_id(ec2, 'Dispatcher AMI', publish_dispatcher_criteria),
        'publish': get_most_recent_ami_id(ec2, 'Publish AMI', publish_criteria),
        'author': get_most_recent_ami_id(ec2, 'Author AMI', author_criteria),
        'author_publish_dispatcher': get_most_recent_ami_id(ec2, 'AuthorPublishDispatcher AMI', author_publish_disp_criteria),
        'orchestrator': get_most_recent_ami_id(ec2, 'Java AMI', orchestrator_criteria),
        'chaos_monkey': get_most_recent_ami_id(ec2, 'Java AMI', chaos_monkey_criteria),
    }

    write_file(out_file, ami_ids, aem_profile, os_type, jdk_type)

    module.exit_json(changed=True)

if __name__ == '__main__':
    main()
