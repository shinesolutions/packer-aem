# Changelog
All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Changed
- Upgrade aem_resources to 3.6.0, aem_curator to 1.9.0
- Upgrade ruby_aem to 2.5.0

## [3.5.0] - 2019-01-31

### Added
- Parameter for defining aem healthcheck version
- Add platform_type fact to hieradata for configuring repository volume setup
- Create s3 bucket during packer instance profile creation using CFN to store AEM artifacts

### Changed
- Update default Dispatcher download URL #103
- Update Apache Dispatcher Module version to 4.3.1
- Upgrade aem_resources to 3.5.0, aem_curator to 1.7.0
- Upgrade default AEM profile to aem64_sp3
- Upgrade ruby_aem to 2.4.0
- Lock down bundler on host gem to version 1.17.3 in order to support Ruby older than 2.3.0
- Modified TLS private key to download from AWS Secrets Manager or S3 as a fallback
- Move AEM license storage from S3 to AWS Systems Manager Parameter Store secure string

### Removed
- Hiera config parameter duplications

### Fixed
- InSpec awslogs service enabled and running test #60
- InSpec cq.pid file not exists test #60

## [3.4.2] - 2018-12-12

### Changed
- Update OS base package installation
- Add os base package bind-utils
- Add JSON, YAML, Python, and Rubocop checks to lint target
- Change changelog format to adhere keep-a-changelog standard

### Removed
- Move examples user config to https://github.com/shinesolutions/aem-helloworld-config

## [3.4.1] - 2018-12-05

### Added
- Add component check to test for ruby library version #99

### Changed
- Fixed AEM Keystore path for component tests
- Extend component test to verify AEM Keystore contains the imported key #95
- Upgrade ruby_aem to 2.2.1 for https truststore config fix

## [3.4.0] - 2018-11-28

### Changed
- Move TLS certificate storage from S3 to AWS Certificate Manager #41
- Move TLS certificate's private key storage from S3 to AWS Secrets Manager #47
- Upgrade puppet-amazon-ssm-agent to 0.9.3
- Upgrade puppet-aem-curator to 1.3.0
- Upgrade puppet-aem-resources to 3.3.0
- Upgrade ruby_aem to 2.2.0 for SAML support

## [3.3.0] - 2018-10-22

### Added
- Add tomcat service installation for java component #89

### Changed
- Upgrade puppet-aem-resources to 3.2.1, puppet-aem-curator to 1.2.3
- Upgrade example config AEM profile for AEM 6.4 to aem64_sp2
- Increase post AEM stop delay to 5 minutes, to match service post stop timeout
- Add InSpec check to ensure cq.pid doesn't exist on author, publish, author-publish-dispatcher components
- Fix Puppet installation error due to renamed rpm URL
- Upgrade puppet-aem-resources to 3.2.0, puppet-aem-curator to 1.2.2

### Removed
- Move Puppet AEM resource stopped status check from Packer templates to puppet-aem-curator

## [3.2.0] - 2018-09-12

### Added
- Add CloudWatch config for SSM commands offline-snapshot
- Add CloudWatch config for SSM commands offline-compaction-snapshot
- Add CloudWatch config for SSM commands manage-service
- Add CloudWatch config for SSM commands wait-until-ready

### Changed
- Update Cloudwatch config date format for cloud init logfile
- Modify proxy setting config file for CloudWatch to /var/awslogs/etc/proxy.conf
- Lock down awscli version to 1.16.10 let it determine boto dependencies when awscli installation is enabled
- Lock down boto3 to 1.8.5

### Removed
- Remove AMI ID variable file support

## [3.1.0] - 2018-08-10

### Added
- Add AEM Hello World Custom Image Provisioner to integration test #79
- Add new configuration custom_image_provisioner.pre.timeout and custom_image_provisioner.post.timeout

### Changed
- Upgrade ruby_aem to 2.1.0
- Upgrade aem_curator and aem_resources to support new system users provisioning

## [3.0.1] - 2018-07-11

### Added
- Add Custom Image Provisioner pre and post steps support #77

### Changed
- Upgrade example config AEM profiles to aem62_sp1_cfp15, aem63_sp2_cfp2, and aem64_sp1

## [3.0.0] - 2018-07-07

### Changed
- Upgrade ruby_aem to 2.0.0, puppet-aem-resources to 3.0.0, and puppet-aem-curator to 1.0.0 for AEM 6.4 support

## [2.8.0] - 2018-06-27

### Added
- Add CloudWatch config for content health check cron log

## [2.7.3] - 2018-06-20

### Changed
- Upgrade ruby_aem_aws to 1.1.0
- Lock down nokogiri to 1.8.2 due to additional package dependencies in 1.8.3

## [2.7.2] - 2018-06-01

### Changed
- Upgrade ruby_aem_aws to 1.0.0

## [2.7.1] - 2018-05-31

### Added
- Add support for AEM 6.3 SP2 CFP1 AMI baking

### Removed
- Move CodeBuild and CodePipeline support to aem-platform-ci repo

## [2.7.0] - 2018-05-10

### Added
- Add AEM start options support
- Initial experimental effort to support Docker platform type

### Changed
- Rename all component targets to platform-component targets
- Fix aws-cli and CloudWatch logs config flags conditional check

## [2.6.0] - 2018-04-24

### Added
- Add InSpec AEM testing support
- Add support to create AMIs on AWS CodeBuild and CodePipeline
- Add support for AEM 6.4 AMI baking

### Changed
- Increase minimum Ansible version requirement to 2.5.0

## [2.5.0] - 2018-04-10

### Added
- Add config-examples-- make targets
- Add CloudWatch logging for Dispatchers (Author and Publish), Orchestrator and Chaos Monkey
- Add platform_type configuration #71
- Add aws.root_volume_size and aws.data_volume_size configurations #69

### Changed
- Fix SSM agent proxy configuration support
- Set Ansible config hash behaviour to merge
- Replace Stack Builder AMI IDs config generation Python script with Ansible module

## [2.4.0] - 2018-03-04

### Added
- Explicit installation of libtool, autoconf, and automake for native package compilation
- Add CentOS OS type support #65
- Add OS Type system tag
- Add aws.install_ssm_agent configuration

## [2.3.2] - 2018-02-05

### Changed
- Fix Cumulative Fix Pack support due to new naming convention in AEM 6.3 for CFPs

### Removed
- Remove lint and validate dependency from Makefile package target #63
- Move Collectd configuration from packer-aem to aem-aws-stack-provisioner

## [2.3.1] - 2018-01-31

### Added
- Add support for AEM 6.3 SP1 CFP2

## [2.3.0] - 2018-01-29

### Added
- Add no_proxy, aws.vpc_id, and aws.subnet_id configurations

### Changed
- Enabled installation of Amazon SSM Agent by default
- Fixed cloud_writer.py. Added third argument while loading Flusher module #58
- Upgrade ruby_aem to 1.4.1 for nokogiri security vulnerability fix

## [2.2.0] - 2018-01-05

### Added
- Add Application Profile system tag #53
- Add OS type configuration support #54
- Add AEM Dispatcher version configuration
- Add Ansible module packer_tags for adding custom tags to Packer templates
- Add AEM Dispatcher listen ports testing
- Introduce generic YAML configuration using Ansible #52

### Changed
- Replace Serverspec with InSpec for testing #42
- Fix AEM Dispatcher not listening on port 443

## [2.1.0] - 2017-11-29

### Added
- Added AuthorPublishDispatcher component
- Added RHEL 7.x support
- Introduce component-specific Packer config #44
- Add Packer user variables for http_proxy, https_proxy, and no_proxy #45
- Add setconfig.sh script to specify hieradata and packer customisation

### Changed
- Service names are now 'aem-author' (AEM Author) and 'aem-publish' (AEM Publish), previously 'aem-aem'
- Replace default https port for author component from 5433 to 5432
- Replace librarian-puppet with r10k for Puppet dependency management
- Replace AEM-specific provisioning manifests with puppet-aem-curator #35
- AEM base is owned by root, AEM installation directory is owned by aem-<aem_id> user
- Remove NewRelic as this should be a customisation #38
- Tags Cost Center, Availability, Owner are no longer included by default #37
- Volumes created during AMI baking are now tagged via run_volume_tags #50
- Upgrade ruby_aem to 1.4.0
- Upgrade Puppet to version 5
- Default ami_var_file is stage/ami-ids.json
- ami_var_file no longer update source_ami and remove underscore ami postfix
- Stack Builder-specific AMI IDs config script file is now named scripts/create-stack-builder-ami-ids-config.py
- Fix intermittent AEM installation error 500 loop

## [1.1.0] - 2017-06-02

### Changed
- Upgrade AEM Cumulative Fix Pack to SP1-CFP3
- Update to Java Version 8u131
- Update puppet module aco-oracle_java - support Java '8u131'
- Upgrade ruby_aem to 1.3.0

## [1.0.0] - 2017-05-22

### Added
- Initial version
