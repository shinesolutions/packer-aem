[![Build Status](https://img.shields.io/travis/shinesolutions/packer-aem.svg)](http://travis-ci.org/shinesolutions/packer-aem)

Packer AEM
----------

Packer AEM is a set of [Packer](https://www.packer.io/) templates for creating [Adobe Experience Manager (AEM)](http://www.adobe.com/au/marketing-cloud/enterprise-content-management.html) machine and container images, which include the following components:

* `author` - contains [AEM Author](https://helpx.adobe.com/experience-manager/6-3/sites/authoring/using/author.html)
* `publish` - contains [AEM Publish](https://helpx.adobe.com/experience-manager/6-3/sites/authoring/using/author.html)
* `dispatcher` - contains [AEM Dispatcher](https://helpx.adobe.com/experience-manager/dispatcher/using/dispatcher.html)
* `java` - contains [Oracle JDK](http://www.oracle.com/technetwork/java/javase/downloads/index.html), to be used for running [AEM Orchestrator](https://github.com/shinesolutions/aem-orchestrator) and [Chaos Monkey](https://netflix.github.io/chaosmonkey/)
* `author-publish-dispatcher` - contains AEM Author, AEM Publish, and AEM Dispatcher

[![Packer AEM Images](https://raw.github.com/shinesolutions/packer-aem/master/docs/packer-aem-images.png)](https://raw.github.com/shinesolutions/packer-aem/master/docs/packer-aem-images.png)

The AMIs produced by Packer AEM will then be used by [AEM AWS Stack Builder](https://github.com/shinesolutions/aem-aws-stack-builder) to create an AEM environment on [AWS](https://aws.amazon.com/).

Please note that even though Packer AEM currently produces AWS AMIs, we would like to support other image types as well and contributions are welcome. If you have a need to run AEM on other technology stacks, please start a discussion by creating a GitHub issue or email us at [opensource@shinesolutions.com](mailto://opensource@shinesolutions.com).

Installation
------------

- Install the following required tools:
  * [Packer](https://www.packer.io/) version 1.0.0 or later
  * [Packer Post-Processor JSON Updater](https://github.com/cliffano/packer-post-processor-json-updater) version 1.1 or later
  * [Ruby](https://www.ruby-lang.org/en/) version 2.0.0 or later
  * [GNU Make](https://www.gnu.org/software/make/)
- Either clone Packer AEM `git clone https://github.com/shinesolutions/packer-aem.git` or download one of the [released versions](https://github.com/shinesolutions/packer-aem/releases)
- Resolve the [Puppet modules](https://github.com/shinesolutions/packer-aem/blob/master/Puppetfile) and [Ruby gems](https://github.com/shinesolutions/packer-aem/blob/master/Puppetfile) dependencies by running `make deps`

Usage
-----

- Set up [AWS resources required by Packer AEM]()
- Create [Hieradata and Packer vars configuration files]()
- Create the AMIs by running `make <component> version=<version>`
