AWS Resources
-------------

For creating AEM AWS AMIs, the following resources must be available:

- Create an IAM Instance Profile for Packer AEM to use, check out the [example Cloud Formation template](https://github.com/shinesolutions/packer-aem/blob/master/examples/aws/packer-instance-profile.yaml)
- Create an S3 Bucket path for storing AEM artifacts, this bucket path needs to be set in `aws.aem_artifacts_base` [configuration](https://github.com/shinesolutions/packer-aem/blob/master/docs/configuration.md) property
- Upload the required AEM artifacts to the above location, the required artifacts will depend on `aem.profile` configuration. Check out the [artifacts list](https://github.com/shinesolutions/puppet-aem-curator/blob/master/docs/aem-profiles-artifacts.md) required for a given AEM profile
- Upload your certificate to [AWS Certificate Manager (ACM)](https://console.aws.amazon.com/acm/home). The resulting ARN needs to be set in the `aws.certificate_arn` [configuration](https://github.com/shinesolutions/packer-aem/blob/master/docs/configuration.md) property. See [documentation](https://docs.aws.amazon.com/acm/latest/userguide/import-certificate.html)
- TLS key for the certificate above, use one of the following options below (if both are specified, defaulted to AWS Secrets Manager):
  - Create a secret for the certificates key using the [AWS Secrets Manager](https://console.aws.amazon.com/secretsmanager/home). The resulting ARN needs to be set in the `aws.certificate_key_arn` [configuration](https://github.com/shinesolutions/packer-aem/blob/master/docs/configuration.md) property. Please ensure you store the secret **without** a key/value pair.  See [documentation](https://docs.aws.amazon.com/secretsmanager/latest/userguide/manage_create-basic-secret.html)
  - Create an S3 Bucket path for storing the TLS key, this bucket path needs to be set in `aem.certs_base` [configuration](https://github.com/shinesolutions/packer-aem/blob/master/docs/configuration.md) property
