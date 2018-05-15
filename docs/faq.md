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
      Value: Open Source AEM Platform
    - Key: Owner
      Value: Shine Solutions AEM Team
    - Key: Cost Centre
      Value: 12345
  ```
