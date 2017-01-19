[![Build Status](https://img.shields.io/travis/shinesolutions/packer-aem-bootstrap.svg)](http://travis-ci.org/shinesolutions/packer-aem-bootstrap)

# Packer AEM Bootstrap

Packer AEM Bootstrap is a set of [Packer](https://www.packer.io/) templates for creating [Adobe Experience Manager (AEM)](http://www.adobe.com/au/marketing-cloud/enterprise-content-management.html) machine images.

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
make base
```

_todo: add ability to specify the packer builder to use_ 


## Configuration

_todo: simplify, and tidy up configuration_

Packer can be configured in [conf/template-vars.json](https://github.com/shinesolutions/packer-aem-bootstrap/blob/master/conf/template-vars.json).

| Name                | Description   |
| -------------       |:-------------:|
| base_ami_version    |               |
| base_ami_source_ami |               |


Puppet can be configured in [conf/hieradata/common.yaml](https://github.com/shinesolutions/packer-aem-bootstrap/blob/master/conf/hieradata/common.yaml).


| Name            | Description   |
| -------------   |:-------------:|
| base::aws_user  |               |
| base::aws_group |               |




## Development

Validate the packer templates and run the puppet manifests through lint:

```
make validate lint
```


## Acknowledgements


[jmassara/packer-rhel7-vms](https://github.com/jmassara/packer-rhel7-vms) - packer templates for building rhel7 virtual machines.
