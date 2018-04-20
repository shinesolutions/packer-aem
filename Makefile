export PATH := $(PWD)/bin:$(PATH)
AMIS = soe base java author publish dispatcher
VAR_FILES = $(sort $(wildcard vars/*.json))
VAR_PARAMS = $(foreach var_file,$(VAR_FILES),-var-file $(var_file))
ami_var_file ?= stage/ami-ids.json
all_var_files := $(VAR_FILES) $(ami_var_file)
# version: version of machine images to be created
version ?= 1.0.0
# packer_aem_version: version of packer-aem to be packaged
packer_aem_version ?= 2.5.1

package: stage/packer-aem-$(packer_aem_version).tar.gz

stage/packer-aem-$(packer_aem_version).tar.gz: stage
	tar \
	    --exclude='stage*' \
	    --exclude='.git*' \
	    --exclude='.tmp*' \
	    --exclude='.idea*' \
	    --exclude='.DS_Store*' \
	    --exclude='logs*' \
	    --exclude='*.retry' \
	    --exclude='*.iml' \
	    -czf \
		$@ .

ci: clean deps lint validate package

deps:
	gem install bundler
	bundle install --binstubs
	bundle exec r10k puppetfile install --verbose --moduledir modules
	pip install -r requirements.txt

clean:
	rm -rf bin .tmp Puppetfile.lock Gemfile.lock .gems modules packer_cache stage logs/

init:
	chmod +x scripts/*.sh

stage: init
	mkdir -p stage/

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

validate:
	puppet parser validate \
		provisioners/puppet/manifests/*.pp \
		provisioners/puppet/modules/*/manifests/*.pp
	packer validate \
		-syntax-only \
		$(VAR_PARAMS) \
		-var "component=null" \
		templates/generic.json
	packer validate \
		-syntax-only \
		$(VAR_PARAMS) \
		-var "component=null" \
		templates/author-publish-dispatcher.json

config: stage
	scripts/run-playbook.sh set-config "${config_path}"

ami-ids: stage
	scripts/run-playbook.sh create-stack-builder-config "${config_path}"

$(AMIS): stage
	mkdir -p logs/
	PACKER_LOG_PATH=logs/packer-$@.log \
		PACKER_LOG=1 \
		packer build \
		$(VAR_PARAMS) \
		-var-file=vars/components/$@.json \
		-var 'ami_var_file=$(ami_var_file)' \
		-var 'version=$(version)' \
		-only=aws \
		templates/generic.json

author-publish-dispatcher: stage
	mkdir -p logs/
	PACKER_LOG_PATH=logs/packer-$@.log \
		PACKER_LOG=1 \
		packer build \
		$(VAR_PARAMS) \
		-var-file=vars/components/$@.json \
		-var 'ami_var_file=$(ami_var_file)' \
		-var 'version=$(version)' \
		-only=aws \
		templates/$@.json

amis-all: $(AMIS)

var_files:
	@echo $(all_var_files)

merge_var_files:
	@jq -s 'reduce .[] as $$item ({}; . * $$item)' $(all_var_files)

define config_examples
  rm -rf stage/user-config/$(1)-$(2)
	mkdir -p stage/user-config/$(1)-$(2)
	cp examples/user-config/sandpit.yaml stage/user-config/$(1)-$(2)
	cp examples/user-config/$(1).yaml stage/user-config/$(1)-$(2)
	cp examples/user-config/os-$(2).yaml stage/user-config/$(1)-$(2)
	scripts/run-playbook.sh set-config stage/user-config/$(1)-$(2)
endef

config-examples-aem62-rhel7: stage
	$(call config_examples,aem62,rhel7)

config-examples-aem62-amazon-linux2: stage
	$(call config_examples,aem62,amazon-linux2)

config-examples-aem62-centos7: stage
	$(call config_examples,aem62,centos7)

config-examples-aem63-rhel7: stage
	$(call config_examples,aem63,rhel7)

config-examples-aem63-amazon-linux2: stage
	$(call config_examples,aem63,amazon-linux2)

config-examples-aem63-centos7: stage
	$(call config_examples,aem63,centos7)

config-examples-aem64-rhel7: stage
	$(call config_examples,aem64,rhel7)

config-examples-aem64-amazon-linux2: stage
	$(call config_examples,aem64,amazon-linux2)

config-examples-aem64-centos7: stage
	$(call config_examples,aem64,centos7)

create-ci-aws:
	scripts/run-playbook.sh create-ci-aws "${config_path}"

delete-ci-aws:
	scripts/run-playbook.sh delete-ci-aws "${config_path}"

.PHONY: init $(AMIS) amis-all ci clean config lint validate create-ami-ids-yaml var_files merge_var_files package
