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

Please note that even though Packer AEM currently produces AWS AMIs, we would like to support other image types as well and contributions are welcome. If you have a need to run AEM on other technology stacks, please start a discussion by creating a GitHub issue or email us at [opensource@shinesolutions.com](mailto://opensource@shinesolutions.com).

Installation
------------

- Install the following required tools:
  * [Packer](https://www.packer.io/) version 1.0.0 or later
  * [Packer Post-Processor JSON Updater](https://github.com/cliffano/packer-post-processor-json-updater) version 1.2 or later
  * [Ruby](https://www.ruby-lang.org/en/) version 2.1.0 or later
  * [Python](https://www.python.org/downloads/) version 2.7.x
  * [GNU Make](https://www.gnu.org/software/make/)
- Either clone Packer AEM `git clone https://github.com/shinesolutions/packer-aem.git` or download one of the [released versions](https://github.com/shinesolutions/packer-aem/releases)
- Resolve the [Puppet modules](https://github.com/shinesolutions/packer-aem/blob/master/Puppetfile), [Ruby gems](https://github.com/shinesolutions/packer-aem/blob/master/Gemfile), and [Python packages](https://github.com/shinesolutions/packer-aem/blob/master/requirements.txt) dependencies by running `make deps`

Usage
-----

- Set up the required [AWS resources](https://github.com/shinesolutions/packer-aem/blob/master/docs/aws-resources.md)
- Create [configuration file](https://github.com/shinesolutions/packer-aem/blob/master/docs/configuration.md)
- Set up the configuration files by running `make config config_path=<path/to/config/dir>`
- Create the AMIs by running `make <component> version=<version>`, where AMI IDs will be written to stage/ami-ids.json (customisable with `ami_var_file` parameter)

To retrieve the latest AMI IDs for all [AEM AWS Stack Builder](https://github.com/shinesolutions/aem-aws-stack-builder) components, run the command below, and the AMI IDs will be written into `stage/stack-builder-ami-ids.yaml` file that can be consumed as Ansible group vars by AEM AWS Stack Builder:

    AWS_DEFAULT_REGION=<aws_region> scripts/create-stack-builder-ami-ids-config.py

More
----

Further information about Packer AEM:

* [AWS System Tags](https://github.com/shinesolutions/packer-aem/blob/master/docs/aws-system-tags.md)
* [Frequently Asked Questions](https://github.com/shinesolutions/packer-aem/blob/master/docs/faq.md)
