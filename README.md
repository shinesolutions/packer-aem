[![Build Status](https://img.shields.io/travis/shinesolutions/packer-aem-bootstrap.svg)](http://travis-ci.org/shinesolutions/packer-aem-bootstrap)

# Packer AEM Bootstrap

Packer AEM Bootstrap is a set of [Packer](https://www.packer.io/) templates for creating [Adobe Experience Manager (AEM)](http://www.adobe.com/au/marketing-cloud/enterprise-content-management.html) machine and container images.

Simply use these templates as a baseline and customise them to suit your infrastructure.

[![Packer AEM Bootstrap Diagram](https://raw.github.com/shinesolutions/packer-aem-bootstrap/master/docs/packer-aem-bootstrap.png)](https://raw.github.com/shinesolutions/packer-aem-bootstrap/master/docs/packer-aem-bootstrap.png)



## Installation

Requirements
* [Packer](https://www.packer.io/)
* [Packer Post-Processor JSON Updater](https://github.com/cliffano/packer-post-processor-json-updater)
* [Ruby](https://www.ruby-lang.org/en/)
* [GNU Make](https://www.gnu.org/software/make/) (optional, see Makefile to use commands instead)


Install [Puppet](https://puppet.com/), [puppet-lint](http://puppet-lint.com/) and [Librarian-puppet](https://github.com/voxpupuli/librarian-puppet):
```
make tools
```

Install puppet dependencies:
```
make deps
```


Puppet Modules used for installing and configuring the software in the images (See [Puppetfile](https://github.com/shinesolutions/packer-aem-bootstrap/blob/master/Puppetfile))

* [bstopp/aem](https://github.com/bstopp/puppet-aem)
* [puppet/archive](https://github.com/voxpupuli/puppet-archive)
* [maestrodev/wget](https://github.com/maestrodev/puppet-wget)
* [puppetlabs/apache](https://github.com/puppetlabs/puppetlabs-apache)
* [tylerwalts/jdk_oracle](https://github.com/tylerwalts/puppet-jdk_oracle)
* [bashtoni/timezone](https://github.com/BashtonLtd/puppet-timezone)
* [jfryman/selinux](https://github.com/voxpupuli/puppet-selinux)
* [pcfens/rhn_register](https://github.com/pcfens/puppet-rhn_register)
* [stankevich/python](https://github.com/stankevich/puppet-python)
* [kemra102/cloudwatchlogs](https://github.com/kemra102/puppet-cloudwatchlogs)
* [shinesolutions/aem_resources](https://github.com/shinesolutions/puppet-aem-resources)


## Usage

Execute the make command with the name of the packer template you want build.

Example:

To build the base machine image:

```
make base version=1.0.1
```

_todo: add ability to specify the packer builder to use_ 


## Configuration

Packer Building can be configured in the [conf/template-vars.json](https://github.com/shinesolutions/packer-aem-bootstrap/blob/master/conf/template-vars.json) file.

Packer amazon-ebs reference: https://www.packer.io/docs/builders/amazon-ebs.html

| Name                | Description   |
| -------------       |:-------------:|
| aem_base_ami_source_ami | The initial AMI used as a base for the newly created machine (the ami created from the java build) |
| aem_base_instance_type | The EC2 instance type to use while building the aem_base AMI (m3.large) |
| aem_license_source | The location of the aem license file to uploaded to the author and publish ami |
| aem_quickstart_source | The location of the aem cq quickstart file to uploaded to the aem_base for use in the author and publish ami |
| ami_users | A list of account IDs that have access to launch the resulting AMI(s) |
| author_ami_source_ami | The initial AMI used as a base for the newly created machine (the ami created from the aem_base build) |
| author_instance_type | The EC2 instance type to use while building the author AMI (m3.large) |
| aws_region | The name of the region, such as us-east-1, in which to launch the EC2 instance to create the AMI |
| aws_security_group_id | The ID (not the name) of the security group to assign to the instance. By default this is not set and Packer will automatically create a new temporary security group to allow SSH access |
| aws_subnet_id | If using VPC, the ID of the subnet, such as subnet-12345def, where Packer will launch the EC2 instance |
| aws_user | The ssh_username to use when building the ami using the amazon-ebs builder |
| aws_vpc_id | If launching into a VPC subnet, Packer needs the VPC ID in order to create a temporary security group within the VPC |
| base_ami_source_ami | The initial AMI used as a base for the newly created machine (e.g the Red Hat Enterprise Linux 7 AMI provider by Amazon) |
| base_instance_type | The EC2 instance type to use while building the base AMI (t2.micro) |
| base_provisioner_script | The path to a script to upload and execute in the base machine. This path can be absolute or relative. (provisioners/base.sh) |
| cost_center | Tag Value - Used to identify the cost center or business unit associated with a resource; typically for cost allocation and tracking |
| dispatcher_ami_source_ami | The initial AMI used as a base for the newly created machine (the ami created from the httpd build) |
| dispatcher_instance_type | The EC2 instance type to use while building the dispatcher AMI (t2.micro) |
| httpd_ami_source_ami | The initial AMI used as a base for the newly created machine (the ami created from the base build) |
| httpd_instance_type | The EC2 instance type to use while building the httpd AMI (t2.micro) |
| iam_instance_profile | The name of an IAM instance profile to launch the EC2 instance with. |
| iso_sha256 | The checksum for the OS ISO file. Because ISO files are so large, this is required and Packer will verify it prior to booting a virtual machine with the ISO attached |
| iso_url | A URL to the ISO containing the installation image. This URL can be either an HTTP URL or a file URL (or path to a file) |
| java_ami_source_ami | The initial AMI used as a base for the newly created machine (the ami created from the base build) |
| java_instance_type | The EC2 instance type to use while building the java AMI (t2.micro) |
| owner | Tag Value - Used to identify who is responsible for the resource |
| publish_ami_source_ami | The initial AMI used as a base for the newly created machine (the ami created from the aem_base build) |
| publish_instance_type | The EC2 instance type to use while building the publish AMI (m3.large) |
| puppet_bin_dir | The location where puppet exists within the AMI (/opt/puppetlabs/bin) |
| vm_name | This is the name of the OVF file for the new virtual machine, without the file extension |



Puppet Provisioning can be configured in the [conf/hieradata/common.yaml](https://github.com/shinesolutions/packer-aem-bootstrap/blob/master/conf/hieradata/common.yaml) file.

_todo: populate configuration items. specify items in hieradata yaml files. mention how to configure 3rd party puppet modules_ 

| Name            | Description   |
| -------------   |:-------------:|
| packer_user  |               |
| packer_group |               |




## Development

Validate the packer templates and run the puppet manifests through lint:

```
make validate lint
```


## Acknowledgements


[jmassara/packer-rhel7-vms](https://github.com/jmassara/packer-rhel7-vms) - packer templates for building rhel7 virtual machines.
