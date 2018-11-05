Upgrade Guide
-------------

This upgrade guide covers the changes required when you already use Packer AEM and you need to upgrade it to a higher version.

### To 3.4.0

* Remove `aws.aem_certs_base` configuration property
* Move TLS certificate from S3 to AWS Certificate Manager
* Add `aws.certificate_arn` configuration property with value of the ARN of the TLS certificate in AWS Certificate Manager
* Move TLS private key from S3 to AWS Secrets Manager
* Add `aws.certificate_key_arn` configuration property with value of the ARN of the TLS certificate's private key in AWS Secrets Manager
