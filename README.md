[![Build Status](https://img.shields.io/travis/shinesolutions/packer-aem-bootstrap.svg)](http://travis-ci.org/shinesolutions/packer-aem-bootstrap)

# Packer AEM Bootstrap

Packer AEM Bootstrap is a set of [Packer](https://www.packer.io/) templates for creating [Adobe Experience Manager (AEM)](http://www.adobe.com/au/marketing-cloud/enterprise-content-management.html) machine images.

Simply use these templates as a baseline and customise them to suit your infrastructure.

[![Packer AEM Bootstrap Diagram](https://raw.github.com/shinesolutions/packer-aem-bootstrap/master/docs/packer-aem-bootstrap.png)](https://raw.github.com/shinesolutions/packer-aem-bootstrap/master/docs/packer-aem-bootstrap.png)



## Installation

Requirements
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


Puppet Modules used for Provisioning

See [Puppetfile](https://github.com/shinesolutions/packer-aem-bootstrap/blob/master/Puppetfile)

* [bstopp/aem](https://github.com/bstopp/puppet-aem)
* [puppet/archive](https://github.com/voxpupuli/puppet-archive)
* [maestrodev/wget](https://github.com/maestrodev/puppet-wget)
* [puppetlabs/apache](https://github.com/puppetlabs/puppetlabs-apache)
* [tylerwalts/jdk_oracle](https://github.com/tylerwalts/puppet-jdk_oracle)
* [bashtoni/timezone](https://github.com/BashtonLtd/puppet-timezone)
* [jfryman/selinux](https://github.com/voxpupuli/puppet-selinux)



## Usage






## Configuration



