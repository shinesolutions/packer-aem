#!/usr/bin/python

# Generate a YAML file which contains the AMI IDs for all Stack Builder components.
# The AMI IDs are filtered based on AEM Profile and OS Type.
# The YAML file is designed to be dropped directly in Stack Builder configuration path.

from ansible.module_utils.basic import AnsibleModule
from dateutil.parser import parse as parse_dt
import sys, os, argparse, yaml, boto3

def get_most_recent_ami_id(ec2, application_name, application_role, application_profile, os_type):
    filters = [{
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
    }]

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

def write_file(out_file_name, ami_ids):
    out_file = open(out_file_name, 'w')

    yaml.dump({
        'ami_ids': ami_ids
    }, out_file, default_flow_style=False)

def main():

    module = AnsibleModule(
      argument_spec = dict(
          aem_profile = dict(required=True, type='str'),
          os_type = dict(required=True, type='str'),
          out_file = dict(required=True, type='str'),
          region = dict(required=True, type='str'),
      )
    )

    aem_profile = module.params['aem_profile']
    os_type = module.params['os_type']
    out_file = module.params['out_file']
    region = module.params['region']

    ec2 = boto3.resource('ec2', region_name=region)

    ami_ids = {
        'author_dispatcher': get_most_recent_ami_id(ec2, 'Dispatcher AMI', 'dispatcher AMI', aem_profile, os_type),
        'publish_dispatcher': get_most_recent_ami_id(ec2, 'Dispatcher AMI', 'dispatcher AMI', aem_profile, os_type),
        'publish': get_most_recent_ami_id(ec2, 'Publish AMI', 'publish AMI', aem_profile, os_type),
        'author': get_most_recent_ami_id(ec2, 'Author AMI', 'author AMI', aem_profile, os_type),
        'author_publish_dispatcher': get_most_recent_ami_id(ec2, 'AuthorPublishDispatcher AMI', 'author-publish-dispatcher AMI', aem_profile, os_type),
        'orchestrator': get_most_recent_ami_id(ec2, 'Java AMI', 'java AMI', aem_profile, os_type),
        'chaos_monkey': get_most_recent_ami_id(ec2, 'Java AMI', 'java AMI', aem_profile, os_type),
    }

    write_file(out_file, ami_ids)

    module.exit_json(changed = True)

if __name__ == '__main__':
    main()
