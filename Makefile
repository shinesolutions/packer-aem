VAR_FILES = $(sort $(wildcard conf/packer/vars/*.json))
VAR_PARAMS = $(foreach var_file,$(VAR_FILES),-var-file $(var_file))

# version: version of machine images to be created
version ?= 1.0.0
# packer_aem_version: version of packer-aem to be packaged
packer_aem_version ?= 4.3.0-pre.0
aem_helloworld_custom_image_provisioner_version = 0.9.0

ci: clean deps lint package

clean:
	rm -rf bin .bundle .tmp Puppetfile.lock Gemfile.lock .gems modules packer_cache stage logs/

stage:
	mkdir -p stage/ stage/custom/ stage/user-config/ stage/certs/ logs/

package: stage
	tar \
	    --exclude='stage*' \
			--exclude='.bundle' \
			--exclude='bin' \
	    --exclude='.git*' \
	    --exclude='.tmp*' \
	    --exclude='.idea*' \
	    --exclude='.DS_Store*' \
	    --exclude='logs*' \
	    --exclude='*.retry' \
	    --exclude='*.iml' \
	    -czf \
		stage/packer-aem-$(packer_aem_version).tar.gz .

publish:
	putasset \
	  --owner shinesolutions \
	  --repo packer-aem \
		--tag $(packer_aem_version) \
		--file stage/packer-aem-$(packer_aem_version).tar.gz \
		--show-url

################################################################################
# Dependencies resolution targets.
# For deps-local and deps-test-local targets, the local dependencies must be
# available on the same directory level where packer-aem is at. The idea is
# that you can test Packer AEM while also developing those dependencies locally.
################################################################################

# resolve dependencies from remote artifact registries
deps:
	gem install bundler --version=1.17.3
	bundle install --binstubs
	bundle exec r10k puppetfile install --verbose --moduledir modules
	pip install -r requirements.txt
	# TODO: remove when switching back to bstopp/puppet-aem
	# only needed while using shinesolutions/puppet-aem fork
	rm -rf modules/aem/.git

# resolve AEM OpenCloud's Puppet module dependencies from local directories
deps-local:
	rm -rf modules/aem_resources/*
	rm -rf modules/aem_curator/*
	rm -rf modules/amazon_ssm_agent/*
	cp -R ../puppet-aem-resources/* modules/aem_resources/
	cp -R ../puppet-aem-curator/* modules/aem_curator/
	cp -R ../puppet-amazon-ssm-agent/* modules/amazon_ssm_agent/

# resolve test dependencies from remote artifact registries
deps-test: stage
	wget "https://github.com/shinesolutions/aem-helloworld-custom-image-provisioner/releases/download/${aem_helloworld_custom_image_provisioner_version}/aem-helloworld-custom-image-provisioner-${aem_helloworld_custom_image_provisioner_version}.tar.gz" \
	  -O stage/custom/aem-custom-image-provisioner.tar.gz
	rm -rf stage/aem-helloworld-config/ stage/user-config/*
	cd stage && git clone https://github.com/shinesolutions/aem-helloworld-config
	cp -R stage/aem-helloworld-config/packer-aem/* stage/user-config/

# resolve test dependencies from local directories
deps-test-local: stage
	cd ../aem-helloworld-custom-image-provisioner && make package
	rm -rf stage/custom/aem-custom-image-provisioner.tar.gz
	cp ../aem-helloworld-custom-image-provisioner/stage/*.tar.gz stage/custom/aem-custom-image-provisioner.tar.gz
	rm -rf stage/aem-helloworld-config/ stage/user-config/*
	cp -R ../aem-helloworld-config/packer-aem/* stage/user-config/

################################################################################
# Code styling check and validation targets:
# - lint Packer variable files and templates
# - lint Ansible inventory files, tools configuration files
# - lint Gemfile and InSpec test files
# - lint Puppet manifests
# - lint custom Ansible modules
# - check shell scripts
# - validate Puppet manifests
# - validate Packer templates
################################################################################

lint:
	jsonlint conf/packer/vars/components/*.json templates/packer/*/*.json
	yaml-lint *.yml .*.yml conf/ansible/inventory/group_vars/* conf/puppet/hieradata/*.yaml conf/puppet/hieradata/*/*.yaml
	bundle exec rubocop Gemfile test/inspec/*.rb
	bundle exec puppet-lint \
		--fail-on-warnings \
		--no-140chars-check \
		--no-autoloader_layout-check \
		--no-documentation-check \
		--no-only_variable_string-check \
		--no-selector_inside_resource-check \
		provisioners/puppet/manifests/*.pp \
		provisioners/puppet/modules/*/manifests/*.pp
	pylint provisioners/ansible/library/*.py
	shellcheck $$(find provisioners scripts -name '*.sh')
	puppet parser validate \
		provisioners/puppet/manifests/*.pp \
		provisioners/puppet/modules/*/manifests/*.pp
	$(call validate_packer_template,templates/packer/aws/generic.json)
	$(call validate_packer_template,templates/packer/aws/author-publish-dispatcher.json)
	$(call validate_packer_template,templates/packer/docker/generic.json)

define validate_packer_template
	packer validate \
		-syntax-only \
		$(VAR_PARAMS) \
		-var "component=null" \
		$(1)
endef

################################################################################
# Configuration targets.
################################################################################

# Set Puppet Hieradata, Packer variables and templates based on Packer AEM configuration
config:
	scripts/run-playbook.sh set-config "${config_path}"

################################################################################
# AWS resources targets.
################################################################################

create-aws-resources:
	scripts/run-playbook-stack.sh create-aws-resources "${config_path}" "${stack_prefix}"

delete-aws-resources:
	scripts/run-playbook-stack.sh delete-aws-resources "${config_path}" "${stack_prefix}"

################################################################################
# Machine image build targets.
################################################################################

# build AWS AMIs
aws-java aws-author aws-publish aws-dispatcher: stage config
	$(eval COMPONENT := $(shell echo $@ | sed -e 's/^aws-//g'))
	PACKER_LOG_PATH=logs/packer-$@.log \
		PACKER_LOG=1 \
		packer build \
		$(VAR_PARAMS) \
		-var-file=conf/packer/vars/components/$(COMPONENT).json \
		-var 'version=$(version)' \
		templates/packer/aws/generic.json

# build AWS AMI for author-publish-dispatcher component
aws-author-publish-dispatcher: stage config
	PACKER_LOG_PATH=logs/packer-$@.log \
		PACKER_LOG=1 \
		packer build \
		$(VAR_PARAMS) \
		-var-file=conf/packer/vars/components/author-publish-dispatcher.json \
		-var 'version=$(version)' \
		templates/packer/aws/author-publish-dispatcher.json

# build Docker images
docker-java docker-author docker-publish docker-dispatcher: stage config
	$(eval COMPONENT := $(shell echo $@ | sed -e 's/^docker-//g'))
	PACKER_LOG_PATH=logs/packer-$@.log \
		PACKER_LOG=1 \
		packer build \
		$(VAR_PARAMS) \
		-var-file=conf/packer/vars/components/$(COMPONENT).json \
		-var 'version=$(version)' \
		templates/packer/docker/generic.json

# build Docker image for author-publish-dispatcher component
docker-author-publish-dispatcher: stage config
	PACKER_LOG_PATH=logs/packer-$@.log \
		PACKER_LOG=1 \
		packer build \
		$(VAR_PARAMS) \
		-var-file=conf/packer/vars/components/author-publish-dispatcher.json \
		-var 'version=$(version)' \
		templates/packer/docker/author-publish-dispatcher.json

################################################################################
# Integration test targets.
# In order to save time, integration tests will only execute aws rhel7 aem64 combination.
# The complete tests will be done on AWS CodeBuild/CodePipeline.
################################################################################

test-integration: deps deps-test
	make config config_path=stage/user-config/aws-rhel7-aem64
	./test/integration/test-examples.sh "$(test_id)" aws rhel7 aem64

test-integration-local: deps-local deps-test-local
	make config config_path=../stage/user-config/aws-rhel7-aem64
	./test/integration/test-examples.sh "$(test_id)" aws rhel7 aem64

################################################################################
# Utility targets.
################################################################################

# retrieve latest AMI IDs and create AEM AWS Stack Builder configuration files
ami-ids: stage
	scripts/run-playbook.sh create-stack-builder-config "${config_path}"

# retrieve latest AMI IDs for a predefined combination of environments
# using the AEM Hello World Configuration examples
ami-ids-examples: stage
	$(call ami_ids_examples,aws-rhel7-aem62)
	$(call ami_ids_examples,aws-rhel7-aem63)
	$(call ami_ids_examples,aws-rhel7-aem64)
	$(call ami_ids_examples,aws-amazon-linux2-aem62)
	$(call ami_ids_examples,aws-amazon-linux2-aem63)
	$(call ami_ids_examples,aws-amazon-linux2-aem64)

define ami_ids_examples
	make ami-ids config_path=../aem-helloworld-config/packer-aem/$(1)/
endef

# convenient target for creating self-signed certificate using OpenSSL
create-cert: stage
	openssl req \
	    -new \
	    -newkey rsa:4096 \
			-nodes \
	    -days 365 \
	    -x509 \
	    -subj "/C=AU/ST=Victoria/L=Melbourne/O=AEM OpenCloud/CN=*.aemopencloud.net" \
	    -keyout stage/certs/aem.key \
	    -out stage/certs/aem.cert

.PHONY: ci clean stage package publish deps deps-local deps-test deps-test-local lint config aws-java aws-author aws-publish aws-dispatcher aws-author-publish-dispatcher docker-java docker-author docker-publish docker-dispatcher docker-author-publish-dispatcher test-integration test-integration-local ami-ids ami-ids-examples create-cert
