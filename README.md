[![Build Status](https://img.shields.io/travis/shinesolutions/packer-aem.svg)](http://travis-ci.org/shinesolutions/packer-aem)

# Packer AEM Bootstrap

Packer AEM Bootstrap is a set of [Packer](https://www.packer.io/) templates for creating [Adobe Experience Manager (AEM)](http://www.adobe.com/au/marketing-cloud/enterprise-content-management.html) machine and container images.

Simply use these templates as a baseline and customise them to suit your infrastructure.

[![Packer AEM Bootstrap Diagram](https://raw.github.com/shinesolutions/packer-aem-bootstrap/master/docs/packer-aem-bootstrap.png)](https://raw.github.com/shinesolutions/packer-aem-bootstrap/master/docs/packer-aem-bootstrap.png)



## Installation

Requirements
* [Packer](https://www.packer.io/) version 0.12.2 or later
* [Packer Post-Processor JSON Updater](https://github.com/cliffano/packer-post-processor-json-updater)
* [Ruby](https://www.ruby-lang.org/en/)
* [GNU Make](https://www.gnu.org/software/make/) (optional, see Makefile to use commands instead)

Install [Puppet](https://puppet.com/), [puppet-lint](http://puppet-lint.com/) and [r10k](https://github.com/puppetlabs/r10k):
```
make tools
```

Install Puppet modules dependencies:
```
make deps
```

See [Puppetfile](https://github.com/shinesolutions/packer-aem-bootstrap/blob/master/Puppetfile) for the list of modules.

## Usage

Execute the make command with the name of the packer template you want build.

Example:

To build the base machine image:

```
make base version=1.0.1
```

_todo: add ability to specify the packer builder to use_


## Configuration

### Packer

Packer Building can be configured in the [conf/template-vars.json](https://github.com/shinesolutions/packer-aem-bootstrap/blob/master/conf/template-vars.json) file.

#### amazon-ebs builder

Packer amazon-ebs reference: https://www.packer.io/docs/builders/amazon-ebs.html


| Name                | Description   |
| -------------       |:-------------:|
| aem_base_ami_source_ami | The initial AMI used as a base for the newly created machine (the ami created from the java build) |
| aem_base_instance_type | The EC2 instance type to use while building the aem_base AMI (m4.large) |
| ami_users | A list of account IDs that have access to launch the resulting AMI(s) |
| author_ami_source_ami | The initial AMI used as a base for the newly created machine (the ami created from the aem_base build) |
| author_instance_type | The EC2 instance type to use while building the author AMI (m4.large) |
| aws_region | The name of the region, such as us-east-1, in which to launch the EC2 instance to create the AMI |
| aws_security_group_id | The ID (not the name) of the security group to assign to the instance. By default this is not set and Packer will automatically create a new temporary security group to allow SSH access |
| aws_subnet_id | If using VPC, the ID of the subnet, such as subnet-12345def, where Packer will launch the EC2 instance |
| aws_user | The ssh_username to use when building the ami using the amazon-ebs builder |
| aws_vpc_id | If launching into a VPC subnet, Packer needs the VPC ID in order to create a temporary security group within the VPC |
| base_ami_source_ami | The initial AMI used as a base for the newly created machine (e.g the Red Hat Enterprise Linux 7 AMI provider by Amazon) |
| base_instance_type | The EC2 instance type to use while building the base AMI (t2.micro) |
| base_provisioner_script | The path to a script to upload and execute in the base machine. This path can be absolute or relative. (provisioners/base.sh) |
| dispatcher_ami_source_ami | The initial AMI used as a base for the newly created machine (the ami created from the httpd build) |
| dispatcher_instance_type | The EC2 instance type to use while building the dispatcher AMI (t2.micro) |
| httpd_ami_source_ami | The initial AMI used as a base for the newly created machine (the ami created from the base build) |
| httpd_instance_type | The EC2 instance type to use while building the httpd AMI (t2.micro) |
| iam_instance_profile | The name of an IAM instance profile to launch the EC2 instance with. |
| java_ami_source_ami | The initial AMI used as a base for the newly created machine (the ami created from the base build) |
| java_instance_type | The EC2 instance type to use while building the java AMI (t2.micro) |
| publish_ami_source_ami | The initial AMI used as a base for the newly created machine (the ami created from the aem_base build) |
| publish_instance_type | The EC2 instance type to use while building the publish AMI (m4.large) |
| puppet_bin_dir | The location where puppet exists within the AMI (/opt/puppetlabs/bin) |

#### virtualbox-iso builder

| Name                | Description   |
| -------------       |:-------------:|
| iso_sha256 | The checksum for the OS ISO file. Because ISO files are so large, this is required and Packer will verify it prior to booting a virtual machine with the ISO attached |
| iso_url | A URL to the ISO containing the installation image. This URL can be either an HTTP URL or a file URL (or path to a file) |
| vm_name | This is the name of the OVF file for the new virtual machine, without the file extension |



### Puppet Configuration

Puppet Provisioning can be configured in the [conf/hieradata/common.yaml](https://github.com/shinesolutions/packer-aem-bootstrap/blob/master/conf/hieradata/common.yaml) file.

_todo: populate configuration items. specify items in hieradata yaml files. mention how to configure 3rd party puppet modules_

#### common.yaml

| Name            | Default Value   |
| -------------   |:-------------:|
| packer_user:  | 'ec2-user' |
| packer_group: | 'ec2-user' |
| aem_license_source: | '/tmp/license.properties' |
| aem_sample_content: | false |  


#### base.yaml

| Name            | Default Value   |
| -------------   |:-------------:|
| timezone::region: | 'Australia' |
| timezone::locality: | 'Melbourne' |
| cloudwatchlogs::region: | 'ap-southeast-2' |
| base::packer_user: | "%{hiera('packer_user')}" |
| base::packer_group: | "%{hiera('packer_group')}" |
| base::aws_agents_install_url: | 'https://d1wk0tztpsntt1.cloudfront.net/linux/latest/install' |



#### java.yaml

| Name            | Default Value   |
| -------------   |:-------------:|
| jdk_oracle::version: | '8' |
| jdk_oracle::version_update: | '112' |
| jdk_oracle::version_build: | '15' |



#### author.yaml

| Name            | Default Value   |
| -------------   |:-------------:|
| author::aem_quickstart_source: | "%{hiera('aem_quickstart_source')}" |
| author::aem_license_source: | "%{hiera('aem_license_source')}" |
| author::aem_healthcheck_version: | "%{hiera('aem_healthcheck_version')}" |
| author::aem_sample_content: |  false |
| aem_base::aem_healthcheck_version: | "%{hiera('aem_healthcheck_version')}" |




#### publish.yaml

| Name            | Default Value   |
| -------------   |:-------------:|
| publish::aem_quickstart_source: | "%{hiera('aem_quickstart_source')}" |
| publish::aem_license_source: |  "%{hiera('aem_license_source')}" |
| publish::aem_healthcheck_version: | "%{hiera('aem_healthcheck_version')}" |
| publish::aem_sample_content: | false |
| aem_base::aem_healthcheck_version: | "%{hiera('aem_healthcheck_version')}" |



#### httpd.yaml

Does not contain configuration at this time.

| Name            | Default Value   |
| -------------   |:-------------:|




#### dispatcher.yaml

| Name            | Default Value   |
| -------------   |:-------------:|
| dispatcher::aem_dispatcher_source: | 'https://www.adobeaemcloud.com/content/companies/public/adobe/dispatcher/dispatcher/_jcr_content/top/download_8/file.res/dispatcher-apache2.4-linux-x86-64-4.2.1.tar.gz' |
| dispatcher::filename: | 'dispatcher-apache2.4-linux-x86-64-4.2.1.tar.gz' |
| dispatcher::tmp_dir: | '/tmp/dispatcher-apache2.4-linux-x86-64-4.2.1' |
| dispatcher::module_filename: | 'dispatcher-apache2.4-4.2.1.so' |
| dispatcher::packer_user: | "%{hiera('packer_user')}" |
| dispatcher::packer_group: | "%{hiera('packer_group')}" |



#### 3rd party puppet module configuration




## Development

Validate the packer templates and run the puppet manifests through lint:

```
make validate lint
```


## Acknowledgements


[jmassara/packer-rhel7-vms](https://github.com/jmassara/packer-rhel7-vms) - packer templates for building rhel7 virtual machines.
