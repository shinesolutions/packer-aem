AMIS = base java httpd

ci: tools deps clean lint validate

deps:
	librarian-puppet install --path modules --verbose

clean:
	rm -rf .librarian .tmp Puppetfile.lock

lint:
	puppet-lint \
		--fail-on-warnings \
		--no-140chars-check \
		--no-autoloader_layout-check \
		--no-documentation-check \
		--no-only_variable_string-check \
		--no-selector_inside_resource-check \
		provisioners/*.pp

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
	gem install puppet-lint librarian-puppet

.PHONY: $(AMIS) amis-all ci clean deps lint tools validate
