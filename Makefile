AMIS = soe java author publish dispatcher all-in-one
VAR_FILES = $(sort $(wildcard vars/*.json))
VAR_PARAMS = $(foreach var_file,$(VAR_FILES),-var-file $(var_file))
ami_var_file ?= vars/00_amis.json
version ?= 1.0.0

ci: clean lint validate

modules/.librarian-puppet-has-run: Gemfile.lock Puppetfile
	bundle exec librarian-puppet install --path modules --verbose
	touch modules/.librarian-puppet-has-run

clean:
	rm -rf .librarian .tmp Puppetfile.lock .vagrant output-virtualbox-iso *.box Vagrantfile modules packer_cache

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
	for AMI in $(AMIS); do \
		packer validate \
			-syntax-only \
			$(VAR_PARAMS) \
			-var "component=$$AMI" \
			templates/$$AMI.json; \
	done

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

.PHONY: $(AMIS) amis-all ci clean lint validate var_files
