AMIS = soe base java author publish dispatcher all-in-one
VAR_FILES = $(sort $(wildcard vars/*.json))
VAR_PARAMS = $(foreach var_file,$(VAR_FILES),-var-file $(var_file))
ami_var_file ?= vars/00_amis.json
version ?= 1.0.0
packer_aem_version ?= 0.9.0

stage/packer-aem-$(packer_aem_version).tar.gz: clean lint validate stage
	tar \
	    --exclude='stage*' \
		--exclude-from .gitignore \
	    --exclude='.git*' \
	    --exclude='.librarian*' \
	    --exclude='.tmp*' \
	    --exclude='.idea*' \
	    --exclude='.DS_Store*' \
	    --exclude='logs*' \
	    --exclude='*.retry' \
	    --exclude='*.iml' \
	    -czvf \
		$@

#ci: clean lint validate package
#ci: clean tools deps lint validate package

modules/.librarian-puppet-has-run: Gemfile.lock Puppetfile
	bundle exec librarian-puppet install --path modules --verbose
	touch modules/.librarian-puppet-has-run

clean:
	rm -rf .librarian .tmp Puppetfile.lock .vagrant output-virtualbox-iso *.box Vagrantfile modules packer_cache stage logs/

lint: Gemfile.lock
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
	packer validate \
		-syntax-only \
		$(VAR_PARAMS) \
		-var "component=null" \
		templates/generic.json

#TODO: consider having a var-file for each component - which should include the ami_users variable
$(AMIS): modules/.librarian-puppet-has-run
	mkdir -p logs/
	PACKER_LOG_PATH=logs/packer-$@.log \
		PACKER_LOG=1 \
		packer build \
		$(VAR_PARAMS) \
		-var 'ami_var_file=$(ami_var_file)' \
		-var 'component=$@' \
		-var 'version=$(version)' \
		templates/generic.json

amis-all: $(AMIS)

var_files:
	@echo $(VAR_FILES) $(ami_var_file)

Gemfile.lock: Gemfile
	bundle install

stage:
	mkdir -p stage/

stage/ami-ids.yaml: stage
	scripts/create-ami-ids-yaml.py -o $@

.PHONY: $(AMIS) amis-all ci clean deps lint tools validate create-ami-ids-yaml var_files
