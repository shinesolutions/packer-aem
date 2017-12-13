AWS System Tags
---------------

In order to identify the AWS resources (e.g. EC2 instance, AMI, volumes) that are used as part of AEM AMIs creation process, the following system tags are set up:

| Name | Description |
|------|-------------|
| Version | The `version` parameter value passed to AMI creation command, e.g. `make version=123` |
| Name | The AMI name to be displayed on AWS console `<component> AMI <version>` |
| Application Id | Value is `Adobe Experience Manager (AEM)` |
| Application Role | Value is `<component> AMI` |
| Application Profile | Value is an AEM configured AEM profile |

If you're looking to add custom tags, please check out the [AWS Tags section on configuration page](https://github.com/shinesolutions/packer-aem/blob/master/docs/configuration.md#aws-tags).
