Upgrade Guide
-------------

This upgrade guide covers the changes required when you already use Packer AEM and you need to upgrade it to a higher version.

### To 4.16.0

* Automated downloading of any JDK from Oracle Technology Network is no longer supported. You have to manually download [JDK 8 RPM](https://www.oracle.com/technetwork/java/javase/downloads/jdk8-downloads-2133151.html) from OTN, upload it to a storage location (e.g. S3 bucket path specified in `aem.jdk.base_url`), and then configure the exact RPM file name in `aem.jdk.filename` configuration property. An example RPM file name is `jdk-8u221-linux-x64.rpm`
* If you want to use a custom Dispatcher tarball file, you have to download it from [Macromedia](http://download.macromedia.com/dispatcher/download), upload it to a storage location (e.g. S3 bucket path specified in `aem.dispatcher.apache_module_base_url`). An example file name is `dispatcher-apache2.4-linux-x86_64-ssl-4.3.3.tar.gz`

### To 4.1.0

* Add new `aem.jdk.*` configuration properties
* Add new `aem.dispatcher.ssl_version` configuration property

### To 4.0.0

* The `secretsmanager:GetSecretValue` permission is now optional, it's only needed when using AWS Secrets Manager to store the TLS certificate private key, it's not needed when an S3 bucket is used
* Re-add `aws.aem_certs_base` configuration property and it's only needed when S3 bucket is used to store the TLS certificate private key
* Move AEM license from S3 to AWS Systems Manager Parameter Store as secure string, specify the parameter name in `aws.aem_license` configuration property
* Remove AEM license files from S3, they used to be stored under the path specified in `aws.aem_certs_base` configuration property
* Migrated AEM Java Keystore Value from plain text to AWS Systems Manager Parameters.
* Migrated AEM License parameter to AWS Systems Manager Parameters
* Add support for additional certificate locations in `aws.certificate_arn` (ARN for either ACM/IAM ServerCertificates or an S3 key path)
* rhel7 default data volumes are now `/dev/xvdb` and `/dev/xvdc`, if you used to rely on the previous defaults of `/dev/sdb` and `/dev/sdc`, then you have to explicitly define those configurations

### To 3.4.0

* New service requirements: AWS Certificate Manager and AWS Secrets Manager
* Add `acm:GetCertificate`, `kms:Decrypt`, and `secretsmanager:GetSecretValue` permissions to the role of the IAM Instance Profile's configured in `aws.iam_instance_profile`
* Remove `aws.aem_certs_base` configuration property
* Move TLS certificate from S3 to AWS Certificate Manager
* Add `aws.certificate_arn` configuration property with value of the ARN of the TLS certificate in AWS Certificate Manager
* Move TLS private key from S3 to AWS Secrets Manager
* Add `aws.certificate_key_arn` configuration property with value of the ARN of the TLS certificate's private key in AWS Secrets Manager
