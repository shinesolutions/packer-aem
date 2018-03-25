### 2.4.1
* Fix SSM agent proxy configuration support
* Set Ansible config hash behaviour to merge
* Add config-examples-* make targets
* Add CloudWatch logging for Dispatchers (Author and Publish), Orchestrator and Chaos Monkey

### 2.4.0
* Explicit installation of libtool, autoconf, and automake for native package compilation
* Add CentOS OS type support #65
* Add OS Type system tag
* Add aws.install_ssm_agent configuration

### 2.3.2
* Fix Cumulative Fix Pack support due to new naming convention in AEM 6.3 for CFPs
* Remove lint and validate dependency from Makefile package target #63
* Move Collectd configuration from packer-aem to aem-aws-stack-provisioner

### 2.3.1
* Add support for AEM 6.3 SP1 CFP2

### 2.3.0
* Enabled installation of Amazon SSM Agent by default
* Add no_proxy, aws.vpc_id, and aws.subnet_id configurations
* Fixed cloud_writer.py. Added third argument while loading Flusher module #58
* Upgrade ruby_aem to 1.4.1 for nokogiri security vulnerability fix

### 2.2.0
* Replace Serverspec with InSpec for testing #42
* Add Application Profile system tag #53
* Fix AEM Dispatcher not listening on port 443
* Add AEM Dispatcher listen ports testing
* Introduce generic YAML configuration using Ansible #52
* Add OS type configuration support #54
* Add AEM Dispatcher version configuration
* Add Ansible module packer_tags for adding custom tags to Packer templates

### 2.1.0
* Service names are now 'aem-author' (AEM Author) and 'aem-publish' (AEM Publish), previously 'aem-aem'
* Replace default https port for author component from 5433 to 5432
* Added AuthorPublishDispatcher component
* Added RHEL 7.x support
* Replace librarian-puppet with r10k for Puppet dependency management
* Replace AEM-specific provisioning manifests with puppet-aem-curator #35
* AEM base is owned by root, AEM installation directory is owned by aem-<aem_id> user
* Introduce component-specific Packer config #44
* Add Packer user variables for http_proxy, https_proxy, and no_proxy #45
* Remove NewRelic as this should be a customisation #38
* Add setconfig.sh script to specify hieradata and packer customisation
* Tags Cost Center, Availability, Owner are no longer included by default #37
* Volumes created during AMI baking are now tagged via run_volume_tags #50
* Upgrade ruby_aem to 1.4.0
* Upgrade Puppet to version 5
* Default ami_var_file is stage/ami-ids.json
* ami_var_file no longer update source_ami and remove _ami postfix
* Stack Builder-specific AMI IDs config script file is now named scripts/create-stack-builder-ami-ids-config.py
* Fix intermittent AEM installation error 500 loop

### 2.0.0
* (NEED TO COMPLETE)

### 1.1.0
* Upgrade AEM Cumulative Fix Pack to SP1-CFP3
* Update to Java Version 8u131
* Update puppet module aco-oracle_java - support Java '8u131'
* Upgrade ruby_aem to 1.3.0

### 1.0.0
* Initial version
