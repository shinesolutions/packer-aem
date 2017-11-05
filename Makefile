export PATH := $(PWD)/bin:$(PATH)
AMIS = soe base java author publish dispatcher author-publish-dispatcher all-in-one
VAR_FILES = $(sort $(wildcard vars/*.json))
VAR_PARAMS = $(foreach var_file,$(VAR_FILES),-var-file $(var_file))
ami_var_file ?= vars/00_amis.json
all_var_files := $(VAR_FILES) $(ami_var_file)
version ?= 1.0.0
packer_aem_version ?= 0.9.0

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

Puppetfile.lock: Gemfile.lock Puppetfile
	bundle exec r10k puppetfile install --verbose --moduledir modules

clean:
	rm -rf .tmp Puppetfile.lock Gemfile.lock .gems .vagrant output-virtualbox-iso *.box Vagrantfile modules packer_cache stage logs/

lint: Puppetfile.lock
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

$(AMIS): Puppetfile.lock
	mkdir -p logs/
	PACKER_LOG_PATH=logs/packer-$@.log \
		PACKER_LOG=1 \
		packer build \
		$(VAR_PARAMS) \
		-var-file=vars/components/$@.json \
		-var 'ami_var_file=$(ami_var_file)' \
		-var 'component=$@' \
		-var 'version=$(version)' \
		templates/generic.json

# # For building the author-publish-dispatcher component only
# author-publish-dispatcher: Puppetfile.lock
# 	mkdir -p logs/
# 	PACKER_LOG_PATH=logs/packer-$@.log \
# 		PACKER_LOG=1 \
# 		packer build \
# 		$(VAR_PARAMS) \
# 		-var 'ami_var_file=$(ami_var_file)' \
# 		-var 'component=$@' \
# 		-var 'version=$(version)' \
# 		templates/author-publish-dispatcher.json

amis-all: $(AMIS)

var_files:
	@echo $(all_var_files)

merge_var_files:
	@jq -s 'reduce .[] as $$item ({}; . * $$item)' $(all_var_files)

Gemfile.lock: Gemfile
	bundle install --binstubs

stage:
	mkdir -p stage/

stage/ami-ids.yaml: stage
	scripts/create-ami-ids-yaml.py -o $@

.PHONY: $(AMIS) amis-all ci clean lint validate create-ami-ids-yaml var_files merge_var_files package
