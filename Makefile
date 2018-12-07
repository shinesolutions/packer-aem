VAR_FILES = $(sort $(wildcard conf/packer/vars/*.json))
VAR_PARAMS = $(foreach var_file,$(VAR_FILES),-var-file $(var_file))

# version: version of machine images to be created
version ?= 1.0.0
# packer_aem_version: version of packer-aem to be packaged
packer_aem_version ?= 3.4.1
aem_helloworld_custom_image_provisioner_version = 0.9.0

ci: clean deps lint package

clean:
	rm -rf bin .bundle .tmp Puppetfile.lock Gemfile.lock .gems modules packer_cache stage logs/

stage:
	mkdir -p stage/ stage/custom/ stage/user-config/ logs/

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

################################################################################
# Dependencies resolution targets.
# For deps-local and deps-test-local targets, the local dependencies must be
# available on the same directory level where packer-aem is at. The idea is
# that you can test Packer AEM while also developing those dependencies locally.
################################################################################

# resolve dependencies from remote artifact registries
deps:
	gem install bundler
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

# resolve test dependencies from local directories
deps-test-local: stage
	cd ../aem-helloworld-custom-image-provisioner && make package
	rm -rf stage/custom/aem-custom-image-provisioner.tar.gz
	cp ../aem-helloworld-custom-image-provisioner/stage/*.tar.gz stage/custom/aem-custom-image-provisioner.tar.gz

################################################################################
# Code styling check targets:
# - lint Puppet manifests
# - check shell scripts
# - validate Puppet manifests
# - validate Packer templates
################################################################################

lint:
	bundle exec puppet-lint \
		--fail-on-warnings \
		--no-140chars-check \
		--no-autoloader_layout-check \
		--no-documentation-check \
		--no-only_variable_string-check \
		--no-selector_inside_resource-check \
		provisioners/puppet/manifests/*.pp \
		provisioners/puppet/modules/*/manifests/*.pp
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

# build AWS AMIs for author-publish-dispatcher component
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

################################################################################
# Integration test targets.
# In order to save time, integration tests will only execute aws rhel7 aem64 combination.
# The complete tests will be done on AWS CodeBuild/CodePipeline.
################################################################################

test-integration:
	rm -rf stage/aem-helloworld-config/
	mkdir -p stage/user-config/aws-rhel7-aem64/
	cd stage && git clone https://github.com/shinesolutions/aem-helloworld-config
	cp -R stage/aem-helloworld-config/packer-aem/aws-rhel7-aem64 stage/user-config/
	make config config_path=stage/user-config/aws-rhel7-aem64
	./test/integration/test-examples.sh "$(test_id)" aws rhel7 aem64

test-integration-local: deps-local deps-test-local
	cp -R ../aem-helloworld-config/packer-aem/aws-rhel7-aem64 ../stage/user-config/aws-rhel7-aem64
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
create-cert:
	mkdir -p stage/certs/
	openssl req \
	    -new \
	    -newkey rsa:4096 \
			-nodes \
	    -days 365 \
	    -x509 \
	    -subj "/C=AU/ST=Victoria/L=Melbourne/O=Sample Organisation/CN=*.example.com" \
	    -keyout stage/certs/aem.key \
	    -out stage/certs/aem.cert

.PHONY: ci clean stage package deps deps-local deps-test deps-test-local lint config aws-java aws-author aws-publish aws-dispatcher aws-author-publish-dispatcher docker-java docker-author docker-publish docker-dispatcher test-integration test-integration-local ami-ids create-cert
