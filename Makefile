export PATH := $(PWD)/bin:$(PATH)
AMIS = soe base java author publish dispatcher
VAR_FILES = $(sort $(wildcard vars/*.json))
VAR_PARAMS = $(foreach var_file,$(VAR_FILES),-var-file $(var_file))
ami_var_file ?= stage/ami-ids.json
all_var_files := $(VAR_FILES) $(ami_var_file)
# version: version of machine images to be created
version ?= 1.0.0
# packer_aem_version: version of packer-aem to be packaged
packer_aem_version ?= 2.1.1

package: stage/packer-aem-$(packer_aem_version).tar.gz

stage/packer-aem-$(packer_aem_version).tar.gz: lint validate stage
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

ci: clean lint validate

deps: Gemfile.lock Puppetfile.lock

Puppetfile.lock: Puppetfile
	bundle exec r10k puppetfile install --verbose --moduledir modules

Gemfile.lock: Gemfile
	bundle install --binstubs

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

author-publish-dispatcher:
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

.PHONY: $(AMIS) amis-all ci clean lint validate create-ami-ids-yaml var_files merge_var_files package
