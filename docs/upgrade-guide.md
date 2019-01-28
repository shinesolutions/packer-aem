Upgrade Guide
-------------

This upgrade guide covers the changes required when you already use Packer AEM and you need to upgrade it to a higher version.

### [Unreleased]

* The `secretsmanager:GetSecretValue` permission is now optional, it's only needed when using AWS Secrets Manager to store the TLS certificate private key, it's not needed when an S3 bucket is used
* Re-add `aws.aem_certs_base` configuration property and it's only needed when S3 bucket is used to store the TLS certificate private key
* Move AEM license from S3 to AWS Systems Manager Parameter Store as secure string, specify the parameter name in `aws.aem_license` configuration property
* Remove AEM license files from S3, they used to be stored under the path specified in `aws.aem_certs_base` configuration property

### To 3.4.0

* New service requirements: AWS Certificate Manager and AWS Secrets Manager
* Add `acm:GetCertificate`, `kms:Decrypt`, and `secretsmanager:GetSecretValue` permissions to the role of the IAM Instance Profile's configured in `aws.iam_instance_profile`
* Remove `aws.aem_certs_base` configuration property
* Move TLS certificate from S3 to AWS Certificate Manager
* Add `aws.certificate_arn` configuration property with value of the ARN of the TLS certificate in AWS Certificate Manager
* Move TLS private key from S3 to AWS Secrets Manager
* Add `aws.certificate_key_arn` configuration property with value of the ARN of the TLS certificate's private key in AWS Secrets Manager
