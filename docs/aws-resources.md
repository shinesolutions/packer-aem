AWS Resources
-------------

For creating AEM AWS AMIs, a number of AWS resources must be available.

If you have to provision these resources manually, or to integrate them to your pre-existing mechanism, you can follow the steps below:

- Create an IAM Instance Profile for Packer AEM to use, check out the [example Cloud Formation template](https://github.com/shinesolutions/packer-aem/blob/master/templates/cloudformation/aws-resources.yaml)
- Create an S3 Bucket path for storing AEM artifacts, this bucket path needs to be set in `aws.aem_artifacts_base` [configuration](https://github.com/shinesolutions/packer-aem/blob/master/docs/configuration.md) property
- Upload the required AEM artifacts to the above location, the required artifacts will depend on `aem.profile` configuration. Check out the [artifacts list](https://github.com/shinesolutions/puppet-aem-curator/blob/master/docs/aem-profiles-artifacts.md) required for a given AEM profile
- [Upload your certificate](https://docs.aws.amazon.com/acm/latest/userguide/setup.html) to [AWS Certificate Manager (ACM)](https://console.aws.amazon.com/acm/home). The resulting ARN needs to be set in the `aws.certificate_arn` [configuration](https://github.com/shinesolutions/packer-aem/blob/master/docs/configuration.md) property.
- TLS private key for the certificate above can be configured either in AWS Secrets Manager or on S3. Use one of the following options below (if both are specified, defaulted to AWS Secrets Manager):
  - [Create a secret for the certificates private key](https://docs.aws.amazon.com/secretsmanager/latest/userguide/manage_create-basic-secret.html) using the [AWS Secrets Manager](https://console.aws.amazon.com/secretsmanager/home). The resulting ARN needs to be set in the `aws.certificate_key_arn` [configuration](https://github.com/shinesolutions/packer-aem/blob/master/docs/configuration.md) property. Please ensure you store the secret **without** a key/value pair.
  - Create an S3 Bucket path for storing the private key, this bucket path needs to be set in `aws.aem_certs_base` [configuration](https://github.com/shinesolutions/packer-aem/blob/master/docs/configuration.md) property
- Configure AEM license in AWS Systems Manager Parameter Store by [creating a parameter for the AEM License](https://docs.aws.amazon.com/systems-manager/latest/userguide/sysman-paramstore-su-create.html) using the [AWS Systems Manager](https://console.aws.amazon.com/systems-manager/home). The resulting ARN needs to be set in the `aws.aem_license` [configuration](https://github.com/shinesolutions/packer-aem/blob/master/docs/configuration.md) property. Please ensure you use the **SecureString** type.

However, if you're allowed to provision these resources using CloudFormation stack, you should use the make targets `create-aws-resources` and `delete-aws-resources` .
