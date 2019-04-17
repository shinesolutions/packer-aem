AWS Resources
-------------

For creating AEM AWS AMIs, a number of AWS resources must be available as prerequisites.

### User-managed provisioning

Due to the fact that majority of user's organisation policies requiring SSL/TLS certificate to be managed by the users and not by any external automation process, the following resources must be provisioned by the users:

- [Upload your certificate](https://docs.aws.amazon.com/acm/latest/userguide/setup.html) to [AWS Certificate Manager (ACM)](https://console.aws.amazon.com/acm/home). The resulting ARN needs to be set in the `aws.certificate_arn` [configuration](https://github.com/shinesolutions/packer-aem/blob/master/docs/configuration.md) property.

### CloudFormation stack

If you have the permission to provision the AWS resources using a CloudFormation stack, run the this command to create or update the resources:

    make create-aws-resources stack_prefix=<stack_prefix> config_path=stage/user-config/

The aws-resources stack will contain:

- An IAM Instance Profile with permissions required for Packer AEM
- An S3 Bucket for storing AEM installation and AEM OpenCloud library artifacts, this bucket path needs to be set in `aws.aem_artifacts_base` [configuration](https://github.com/shinesolutions/packer-aem/blob/master/docs/configuration.md) property, and upload the required AEM artifacts to the above location, the required artifacts will depend on `aem.profile` configuration. Check out the [artifacts list](https://github.com/shinesolutions/puppet-aem-curator/blob/master/docs/aem-profiles-artifacts.md) required for a given AEM profile
- AWS Secret Manager secret for storing TLS private key. The resulting ARN needs to be set in the `aws.certificate_key_arn` [configuration](https://github.com/shinesolutions/packer-aem/blob/master/docs/configuration.md) property.
- AEM keystore password Parameter Store variable for storing the password for JDK keystore used by AEM
- AEM license Parameter Store variable. The resulting ARN needs to be set in the `aws.aem_license` [configuration](https://github.com/shinesolutions/packer-aem/blob/master/docs/configuration.md) property

And to delete the resources within the CloudFormation stack:

    make delete-aws-resources stack_prefix=<stack_prefix> config_path=stage/user-config/

### Manual provisioning

Alternatively, if you have to provision these resources manually, or to integrate them into your pre-existing provisioning mechanism, you can follow the steps below as reference:

- Create an IAM Instance Profile for Packer AEM to use, check out the [PackerAemRolePolicy on aws-resources Cloud Formation template](https://github.com/shinesolutions/packer-aem/blob/master/templates/cloudformation/aws-resources.yaml)
- Create an S3 Bucket and a path for storing AEM installation and AEM OpenCloud library artifacts, this bucket path needs to be set in `aws.aem_artifacts_base` [configuration](https://github.com/shinesolutions/packer-aem/blob/master/docs/configuration.md) property
- Upload the required AEM artifacts to the above location, the required artifacts will depend on `aem.profile` configuration. Check out the [artifacts list](https://github.com/shinesolutions/puppet-aem-curator/blob/master/docs/aem-profiles-artifacts.md) required for a given AEM profile
- TLS private key for the certificate above can be configured either in AWS Secrets Manager or on S3. Use one of the following options below (if both are specified, defaulted to AWS Secrets Manager):
  - [Create a secret for the certificates private key](https://docs.aws.amazon.com/secretsmanager/latest/userguide/manage_create-basic-secret.html) using the [AWS Secrets Manager](https://console.aws.amazon.com/secretsmanager/home). The resulting ARN needs to be set in the `aws.certificate_key_arn` [configuration](https://github.com/shinesolutions/packer-aem/blob/master/docs/configuration.md) property. Please ensure you store the secret **without** a key/value pair.
  - Create an S3 Bucket path for storing the private key, this bucket path needs to be set in `aws.aem_certs_base` [configuration](https://github.com/shinesolutions/packer-aem/blob/master/docs/configuration.md) property
- Create AWS Secrets Manager secret and store the JDK keystore password used by AEM
- Configure AEM license in AWS Systems Manager Parameter Store variable by [creating a parameter for the AEM License](https://docs.aws.amazon.com/systems-manager/latest/userguide/sysman-paramstore-su-create.html) using the [AWS Systems Manager](https://console.aws.amazon.com/systems-manager/home). The resulting ARN needs to be set in the `aws.aem_license` [configuration](https://github.com/shinesolutions/packer-aem/blob/master/docs/configuration.md) property. Please ensure you use the **SecureString** type.
