AWS Resources
-------------

For creating AEM AWS AMIs, the following resources must be available:

- Create an IAM Instance Profile for Packer AEM to use, check out the [example Cloud Formation template](https://github.com/shinesolutions/packer-aem/blob/master/examples/packer_instance_profile.yaml)
- Create an S3 Bucket path for storing AEM artifacts
- Upload the required AEM artifacts to the above location, the required artifacts will depend on the AEM profile that you [configure](https://github.com/shinesolutions/packer-aem/blob/master/docs/configuration.md). Check out the [artifacts list](https://github.com/shinesolutions/puppet-aem-curator/blob/master/docs/aem-artifacts.md)
- Create an S3 Bucket path for storing TLS certificate and private key
- Upload the certificate and private key to the above location
