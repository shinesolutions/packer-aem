export PATH := $(PWD)/bin:$(PATH)
AMIS = soe base java author publish dispatcher
VAR_FILES = $(sort $(wildcard vars/*.json))
VAR_PARAMS = $(foreach var_file,$(VAR_FILES),-var-file $(var_file))
ami_var_file ?= stage/ami-ids.json
all_var_files := $(VAR_FILES) $(ami_var_file)
stage_config_path = stage/user-config
# version: version of machine images to be created
version ?= 1.0.0
# packer_aem_version: version of packer-aem to be packaged
packer_aem_version ?= 2.4.1

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

ci: clean lint validate package

deps: Gemfile.lock Puppetfile.lock PythonRequirements.lock

Puppetfile.lock: Puppetfile
	bundle exec r10k puppetfile install --verbose --moduledir modules

Gemfile.lock: Gemfile
	bundle install --binstubs

PythonRequirements.lock: requirements.txt
	pip install -r requirements.txt

clean:
	rm -rf .tmp Puppetfile.lock Gemfile.lock .gems modules packer_cache stage logs/

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
	bundle exec puppet parser validate \
		provisioners/puppet/manifests/*.pp \
		provisioners/puppet/modules/*/manifests/*.pp
	packer validate \
		-syntax-only \
		$(VAR_PARAMS) \
		-var "component=null" \
		templates/generic.json

config:
	scripts/set-config.sh "${config_path}"

$(AMIS): stage
	mkdir -p logs/
	PACKER_LOG_PATH=logs/packer-$@.log \
		PACKER_LOG=1 \
		packer build \
		$(VAR_PARAMS) \
		-var-file=vars/components/$@.json \
		-var 'ami_var_file=$(ami_var_file)' \
		-var 'version=$(version)' \
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
		templates/$@.json

amis-all: $(AMIS)

var_files:
	@echo $(all_var_files)

merge_var_files:
	@jq -s 'reduce .[] as $$item ({}; . * $$item)' $(all_var_files)

stage:
	mkdir -p stage/

stage/ami-ids.yaml: stage
	scripts/create-ami-ids-yaml.py -o $@

define config_examples
	mkdir $(stage_config_path)
	cp examples/user-config/sandpit.yaml $(stage_config_path)
	cp examples/user-config/$(1).yaml $(stage_config_path)
	cp examples/user-config/os-$(2).yaml $(stage_config_path)
	scripts/set-config.sh $(stage_config_path)
endef

config-examples-aem62-rhel7: clean stage
	$(call config_examples,aem62,rhel7)

config-examples-aem62-amazon-linux2: clean stage
	$(call config_examples,aem62,amazon-linux2)

config-examples-aem62-centos7: clean stage
	$(call config_examples,aem62,centos7)

config-examples-aem63-rhel7: clean stage
	$(call config_examples,aem63,rhel7)

config-examples-aem63-amazon-linux2: clean stage
	$(call config_examples,aem63,amazon-linux2)

config-examples-aem63-centos7: clean stage
	$(call config_examples,aem63,centos7)

.PHONY: $(AMIS) amis-all ci clean config lint validate create-ami-ids-yaml var_files merge_var_files package
