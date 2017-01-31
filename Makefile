AMIS = base java httpd aem_base author publish dispatcher all-in-one
var_file ?= conf/aws/rhel7jdk8.json
version ?= 1.0.0

ci: clean tools deps lint validate

deps:
	librarian-puppet install --path modules --verbose

clean:
	rm -rf .librarian .tmp Puppetfile.lock .vagrant output-virtualbox-iso *.box Vagrantfile modules packer_cache

lint:
	puppet-lint \
		--fail-on-warnings \
		--no-140chars-check \
		--no-autoloader_layout-check \
		--no-documentation-check \
		--no-only_variable_string-check \
		--no-selector_inside_resource-check \
		provisioners/puppet/manifests/*.pp \
		provisioners/puppet/modules/*/manifests/*.pp
	shellcheck \
	  provisioners/*/*/*.sh \
	  scripts/*.sh

validate:
	for AMI in $(AMIS); do \
		packer validate \
                        -syntax-only \
			-var-file $(var_file) \
			-var "component=$$AMI" \
			templates/$$AMI.json; \
	done

#TODO: consider having a var-file for each component - which should include the ami_users variable
$(AMIS):
	PACKER_LOG_PATH=/tmp/packer-$@.log \
		PACKER_LOG=1 \
		packer build \
		-var-file $(var_file) \
		-var 'var_file=$(var_file)' \
		-var 'component=$@' \
		-var 'version=$(version)' \
		-var 'ami_users=$(ami_users)' \
		templates/$@.json

amis-all: $(AMIS)

tools:
	gem install puppet puppet-lint librarian-puppet

.PHONY: $(AMIS) amis-all ci clean deps lint tools validate
