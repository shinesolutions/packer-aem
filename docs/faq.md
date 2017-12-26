Frequently Asked Questions
--------------------------

* Q: What is the cause of `Error: /Stage[main]/Aem::Dispatcher/File[/etc/httpd/modules/dispatcher-apache2.4-4.2.2.so]: Could not evaluate: Could not retrieve information from environment production source(s) file:/tmp/shinesolutions/packer-aem/dispatcher-apache2.4-4.2.2.so`?
  A: This is a known error with downloading AEM Dispatcher binary file from Adobe AEM Cloud. When attempting to download version 4.2.2 but it's no longer available because version 4.2.3 has been released, the download URL `https://www.adobeaemcloud.com/content/companies/public/adobe/dispatcher/dispatcher/_jcr_content/top/download_9/file.res/dispatcher-apache2.4-linux-x86-64-ssl-4.2.2.tar.gz` still allows you to download `dispatcher-apache2.4-linux-x86-64-ssl-4.2.2.tar.gz` file, however, the tarball contains `dispatcher-apache2.4-4.2.3.so` instead.
