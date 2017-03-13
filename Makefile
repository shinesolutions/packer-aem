AMIS = soe base java httpd author publish dispatcher all-in-one
VAR_FILES = $(foreach var_file,$(sort $(wildcard vars/*.json)),-var-file $(var_file))
ami_var_file ?= vars/00_amis.json
version ?= 1.0.0

ci: clean tools deps lint validate

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
	shellcheck $(find provisioners scripts -name '*.sh')

validate:
	for AMI in $(AMIS); do \
		packer validate \
			-syntax-only \
			$(VAR_FILES) \
			-var "component=$$AMI" \
			templates/$$AMI.json; \
	done

#TODO: consider having a var-file for each component - which should include the ami_users variable
$(AMIS): modules/.librarian-puppet-has-run
	mkdir -p logs/
	PACKER_LOG_PATH=logs/packer-$@.log \
		PACKER_LOG=1 \
		packer build \
		$(VAR_FILES) \
		-var 'ami_var_file=$(ami_var_file)' \
		-var 'component=$@' \
		-var 'version=$(version)' \
		-var 'ami_users=$(ami_users)' \
		templates/generic.json

amis-all: $(AMIS)

tools:
	gem install puppet puppet-lint librarian-puppet

Gemfile.lock: Gemfile
	bundle install

.PHONY: $(AMIS) amis-all ci clean deps lint tools validate
