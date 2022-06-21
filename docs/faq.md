Frequently Asked Questions
--------------------------

* __Q:__ What is the cause of `Error: /Stage[main]/Aem::Dispatcher/File[/etc/httpd/modules/dispatcher-apache2.4-4.2.2.so]: Could not evaluate: Could not retrieve information from environment production source(s) file:/tmp/shinesolutions/packer-aem/dispatcher-apache2.4-4.2.2.so`?<br/>
  __A:__ This is a known issue with downloading AEM Dispatcher binary file from Adobe AEM Cloud. When attempting to download version 4.2.2 but it's no longer available because the latest version is 4.2.3, the download URL `https://www.adobeaemcloud.com/content/companies/public/adobe/dispatcher/dispatcher/_jcr_content/top/download_9/file.res/dispatcher-apache2.4-linux-x86-64-ssl-4.2.2.tar.gz` still allows you to download `dispatcher-apache2.4-linux-x86-64-ssl-4.2.2.tar.gz` file, however, the tarball contains `dispatcher-apache2.4-4.2.3.so` instead. The solution is simply to update `aem.dispatcher.version` configuration to `4.2.3` .

* __Q:__ How to set up custom AWS tags?<br/>
  __A:__ This can be [configured](https://github.com/shinesolutions/packer-aem/blob/master/docs/configuration.md#aws-platform-type-configuration-properties) in `aws.tags` property. For example:
  ```
  aws:
    tags:
    - Key: Project
      Value: AEM OpenCloud
    - Key: Owner
      Value: Shine Solutions AEM Team
    - Key: Cost Centre
      Value: 12345
  ```

* __Q:__ How to debug the cause of my Custom Image Provisioner failure?<br/>
  __A:__ You can inspect what's going on within the EC2 instance being created by [debugging Packer](https://www.packer.io/docs/other/debugging.html). This can be done by adding `-debug` flag to `packer build` command within Packer AEM's `Makefile`.

* __Q:__ Why do I get an unsupported operation related to encrypted snapshots sharing error `Error modify AMI attributes: UnsupportedOperation: The requested operation is not supported. Images associated with encrypted Snapshots can not be shared.`?
  __A:__ This error can happen when you use a source AMI with an encrypted volume and then you're trying to share it with another AWS account, and this is not supported by AWS. To fix this, you need to remove the user configuration property `aws.ami_users` so that Packer AEM wouldn't try to modify the generated AMI by sharing it with another AWS account.

* __Q:__ What is the cause of `Error: /Stage[main]/Aem_curator::Config_aem_ssl[author: Configure AEM]/Java_ks[cqse:/etc/ssl/aem-author/author.ks]/ensure: change from 'absent' to 'latest' failed: Could not set 'latest' on ensure: key values mismatch file: /tmp/packer-puppet-masterless/module-0/aem_curator/manifests/config_aem_ssl.pp?` <br/>
  __A:__ This error occurs when the certificate and key of the certificate supplied in the config does not match.