AMIS = base java httpd author publish dispatcher all-in-one
var_file ?= conf/aws/aem62rhel7jdk8.json
version ?= 1.0.0
packer_aem_version ?= 0.9.0

ci: clean tools deps lint validate package

deps:
	librarian-puppet install --path modules --verbose
	pip install -r requirements.txt --user

clean:
	rm -rf .librarian .tmp Puppetfile.lock .vagrant output-virtualbox-iso *.box Vagrantfile modules packer_cache stage logs/

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
	mkdir -p logs/
	PACKER_LOG_PATH=logs/packer-$@.log \
		PACKER_LOG=1 \
		packer build \
		-var-file $(var_file) \
		-var 'var_file=$(var_file)' \
		-var 'component=$@' \
		-var 'version=$(version)' \
		-var 'ami_users=$(ami_users)' \
		templates/$@.json

amis-all: $(AMIS)

create-ami-ids-yaml:
	mkdir -p stage/
	scripts/create-ami-ids-yaml.py

tools:
	gem install puppet puppet-lint librarian-puppet

package:
	rm -rf stage
	mkdir -p stage
	tar \
		--exclude='.git*' \
		--exclude='.librarian*' \
		--exclude='.tmp*' \
		--exclude='stage*' \
		--exclude='.idea*' \
		--exclude='.DS_Store*' \
		--exclude='logs*' \
		--exclude='*.retry' \
		--exclude='*.iml' \
		-cvf \
		stage/packer-aem-$(packer_aem_version).tar ./
	gzip stage/packer-aem-$(packer_aem_version).tar

.PHONY: $(AMIS) amis-all ci clean deps lint tools validate create-ami-ids-yaml
