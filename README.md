[![Build Status](https://img.shields.io/travis/shinesolutions/packer-aem.svg)](http://travis-ci.org/shinesolutions/packer-aem)

Packer AEM
----------

Packer AEM is a set of [Packer](https://www.packer.io/) templates for creating [Adobe Experience Manager (AEM)](http://www.adobe.com/au/marketing-cloud/enterprise-content-management.html) machine and container images, which include the following components:

* `author` - contains [AEM Author](https://helpx.adobe.com/experience-manager/6-3/sites/authoring/using/author.html)
* `publish` - contains [AEM Publish](https://helpx.adobe.com/experience-manager/6-3/sites/authoring/using/author.html)
* `dispatcher` - contains [AEM Dispatcher](https://helpx.adobe.com/experience-manager/dispatcher/using/dispatcher.html)
* `java` - contains [Oracle JDK](http://www.oracle.com/technetwork/java/javase/downloads/index.html), to be used for running [AEM Orchestrator](https://github.com/shinesolutions/aem-orchestrator) and [Chaos Monkey](https://netflix.github.io/chaosmonkey/)
* `author-publish-dispatcher` - contains AEM Author, AEM Publish, and AEM Dispatcher

[![Machine Images Diagram](https://raw.github.com/shinesolutions/packer-aem/master/docs/machine-images-diagram.png)](https://raw.github.com/shinesolutions/packer-aem/master/docs/machine-images-diagram.png)

The AMIs produced by Packer AEM will then be used by [AEM AWS Stack Builder](https://github.com/shinesolutions/aem-aws-stack-builder) to create an AEM environment on [AWS](https://aws.amazon.com/).

Packer AEM is part of [AEM OpenCloud](https://shinesolutions.github.io/aem-opencloud/)

Installation
------------

- Either clone Packer AEM `git clone https://github.com/shinesolutions/packer-aem.git` or download one of the [released versions](https://github.com/shinesolutions/packer-aem/releases)
- Install the following required tools:
  * [Packer](https://www.packer.io/) version 1.0.0 or later
  * [Ruby](https://www.ruby-lang.org/en/) version 2.1.0 or later
  * [Python](https://www.python.org/downloads/) version 2.7.x
  * [GNU Make](https://www.gnu.org/software/make/)<br/>

  Alternatively, you can use [AEM Platform BuildEnv](https://github.com/shinesolutions/aem-platform-buildenv) Docker container to run Packer AEM build targets.
- Resolve the [Puppet modules](https://github.com/shinesolutions/packer-aem/blob/master/Puppetfile), [Ruby gems](https://github.com/shinesolutions/packer-aem/blob/master/Gemfile), and [Python packages](https://github.com/shinesolutions/packer-aem/blob/master/requirements.txt) dependencies by running `make deps`

Usage
-----

- Set up the required [AWS resources](https://github.com/shinesolutions/packer-aem/blob/master/docs/aws-resources.md)
- Create [configuration file](https://github.com/shinesolutions/packer-aem/blob/master/docs/configuration.md)
- Apply the configuration files by running `make config config_path=<path/to/config/dir>`
- Create the AMIs by running `make <platform>-<component> version=<version>`, for example: `make aws-author version=1.2.3`

To retrieve the latest AMI IDs for all [AEM AWS Stack Builder](https://github.com/shinesolutions/aem-aws-stack-builder) components, run the command `make ami-ids config_path=<path/to/config/dir>`, and the AMI IDs will be written into `stage/*-stack-builder-ami-ids.yaml` file(s). These files can then be dropped in to AEM AWS Stack Builder configuration path.

Examples
--------

There are a number of [example configuration files](https://github.com/shinesolutions/packer-aem/blob/master/examples/user-config/), you can use those examples as baseline configuration when creating your own machine images:

1. Modify [sandpit.yaml](https://github.com/shinesolutions/packer-aem/blob/master/examples/user-config/sandpit.yaml) with the details of your own environment
2. Run one of the convenient `make config-examples-<platform_type>-<os_type>-<aem_version>` build targets to prepare the configuration, for example, if you want to configure AEM 6.3 build on AWS running RHEL7, run `make config-examples-aws-rhel7-aem63`
3. Finally, create the machine images using the command `make <platform_type>-<component> version=<version>`

More
----

Further information about Packer AEM:

* [AWS Resources](https://github.com/shinesolutions/packer-aem/blob/master/docs/aws-resources.md)
* [AWS System Tags](https://github.com/shinesolutions/packer-aem/blob/master/docs/aws-system-tags.md)
* [Configuration](https://github.com/shinesolutions/packer-aem/blob/master/docs/configuration.md)
* [Customisation Points](https://github.com/shinesolutions/packer-aem/blob/master/docs/customisation-points.md)
* [Frequently Asked Questions](https://github.com/shinesolutions/packer-aem/blob/master/docs/faq.md)
