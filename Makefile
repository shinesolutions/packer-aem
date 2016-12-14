AMIS = base java httpd author publish dispatcher all-in-one

ci: tools deps clean lint validate

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

validate:
	for AMI in $(AMIS); do \
		packer validate \
			-var-file conf/template-vars.json \
			-var "component=$$AMI" \
			templates/$$AMI.json; \
	done

$(AMIS):
	PACKER_LOG_PATH=/tmp/packer-$@.log \
		PACKER_LOG=1 \
		packer build \
		-var-file conf/template-vars.json \
		-var 'component=$@' \
		-var 'version=$(version)' \
		templates/$@.json

amis-all: $(AMIS)

tools:
	gem install puppet puppet-lint librarian-puppet

.PHONY: $(AMIS) amis-all ci clean deps lint tools validate
