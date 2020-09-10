Configuration
-------------

The following configurations are available for users to customise the creation process and the resulting machine images.

Check out the [example configuration files](https://github.com/shinesolutions/aem-helloworld-config/tree/master/packer-aem/) as reference.

### Global configuration properties:

| Name | Description | Required? | Default |
|------|-------------|-----------|---------|
| platform_type | Platform type, currently only supports `aws` | Optional | `aws` |
| os_type | Operating System type, can be `rhel7`, `amazon-linux2`, or `centos7` | Optional | `rhel7` |
| http_proxy | [Web proxy server](https://en.wikipedia.org/wiki/Proxy_server) for http URLs, leave empty if Packer EC2 instances can directly connect to the Internet | Optional | Empty string |
| https_proxy | [Web proxy server](https://en.wikipedia.org/wiki/Proxy_server) for https URLs, leave empty if Packer EC2 instances can directly connect to the Internet | Optional | Empty string |
| no_proxy | A comma separated value of domain suffixes that you don't want to use with the web proxy. | Optional | Empty string |
| timezone.region | [Timezone region name as per tz database list](https://en.wikipedia.org/wiki/List_of_tz_database_time_zones#List) | Optional | `Australia` |
| timezone.locality | [Timezone locality name as per tz database list](https://en.wikipedia.org/wiki/List_of_tz_database_time_zones#List) | Optional | `Melbourne` |
| custom_image_provisioner.pre.timeout | The maximum duration (in seconds) allowed for Custom Image Provisioner pre step to run. | Optional | `3600` |
| custom_image_provisioner.post.timeout | The maximum duration (in seconds) allowed for Custom Image Provisioner post step to run. | Optional | `3600` |
| library.aem_healthcheck_version | The version number of [AEM Health Check](https://github.com/shinesolutions/aem-healthcheck/) library. | Optional | 1.3.3 |



### AEM configuration properties:

| Name | Description | Required? | Default |
|------|-------------|-----------|---------|
| aem.profile | AEM Profile, check out the [list of available profiles](https://github.com/shinesolutions/puppet-aem-curator/blob/master/docs/aem-profiles-artifacts.md) | Optional | `aem62_sp1_cfp9` |
| aem.ssl_method | Method to activate SSL on AEM. Allowed vlaues are `jetty` & `granite`. JDK11 for AEM 6.5 only supports `granite`. | Optional | `jetty` |
| aem.keystore_password_parameter | Parameter store object which contains the [Java Keystore](https://www.digitalocean.com/community/tutorials/java-keytool-essentials-working-with-java-keystores) password used in AEM Author and Publish. Each / represents a subkey in Hiera. This is expected to exist under the root "/" so you must ommit it from the start. For example aem-opencloud/stack_prefix/aem-keystore-password is what goes in the config but becomes /aem-opencloud/stack_prefix/aem-keystore-password on consumption. Note: The Parameter name cannot contain dots/periods. For more information please see: https://puppet.com/docs/puppet/5.4/hiera_automatic.html#hiera-dotted-notation and https://docs.aws.amazon.com/systems-manager/latest/userguide/sysman-parameter-name-constraints.html | Mandatory | |
| aem.author.jvm_mem_opts | AEM Author's memory-specific [JVM arguments](https://docs.oracle.com/cd/E22289_01/html/821-1274/configuring-the-default-jvm-and-java-arguments.html) | Optional | `-Xss4m -Xms4096m -Xmx8192m` |
| aem.author.jvm_opts | AEM Author's [JVM arguments](https://docs.oracle.com/cd/E22289_01/html/821-1274/configuring-the-default-jvm-and-java-arguments.html) | Optional | |
| aem.author.run_modes | A list of AEM Author's feature [run modes](https://helpx.adobe.com/experience-manager/6-5/sites/deploying/using/configure-runmodes.html), e.g. `dynamicmedia_scene7`. There is no need to specify `author` run mode here, it will automatically be added. | Optional | Empty list |
| aem.publish.jvm_mem_opts | AEM Publish's memory-specific [JVM arguments](https://docs.oracle.com/cd/E22289_01/html/821-1274/configuring-the-default-jvm-and-java-arguments.html) | Optional | `-Xss4m -Xms4096m -Xmx8192m` |
| aem.publish.jvm_opts | AEM Publish's [JVM arguments](https://docs.oracle.com/cd/E22289_01/html/821-1274/configuring-the-default-jvm-and-java-arguments.html) | Optional |
| aem.publish.run_modes | A list of AEM Publish's feature run modes, e.g. `dynamicmedia_scene7`. There is no need to specify `publish` run mode here, it will automatically be added. | Optional | Empty list |
| aem.dispatcher.version | AEM Dispatcher version, available version is documented on [Download Dispatcher Web Server Modules](https://www.adobeaemcloud.com/content/companies/public/adobe/dispatcher/dispatcher.html) page | Mandatory | `4.2.3` |
| aem.dispatcher.ssl_version | AEM Dispatcher SSL version, available version depends on what's provided by Adobe on [AEM Dispatcher Release Notes](https://docs.adobe.com/content/help/en/experience-manager-dispatcher/using/getting-started/release-notes.html#apache) page | Optional | `1.0` |
| aem.dispatcher.apache_module_base_url | AEM Dispatcher Apache library base URL.  Source URL can be: `s3://...`, `http://...`, `https://...`, or `file://...`  | Optional | `http://download.macromedia.com/dispatcher/download` |
| aem.artifacts_base | Source URL path of AEM artifacts, it could be `s3://...`, `http://...`, `https://...`, or `file://...`. In [AWS Resources](https://github.com/shinesolutions/packer-aem/blob/master/docs/aws-resources.md) case, it could be an S3 Bucket path, e.g. s3://somebucket/artifacts/.  Object name must be: `aem.key` | Mandatory | |
| aem.enable_custom_image_provisioner | Set to `true` when Custom Image Provisioner pre and post steps will be executed , note: place `aem-custom-image-provisioner.tar.gz` artifact in `stage/custom/` directory | Optional | `false` |
| aem.jdk.base_url | Base URL (just the path, not the file name) where JDK RPM file would be located. URL can be: `s3://...`, `http://...`, `https://...`, or `file://...`. **The download URL `download.oracle.com` is not supported anymore.** | Mandatory | |
| aem.jdk.filename | JDK RPM file name, this file must be located at `aem.jdk.base_url` | Optional | jdk-8u221-linux-x64.rpm |
| aem.jdk.version | JDK version number | Optional | 8 |
| aem.jdk.version_update | JDK update version number | Optional | 221 |

### AWS platform type configuration properties:

| Name | Description | Required? | Default |
|------|-------------|-----------|---------|
| aws.user | SSH username which Packer will use to connect to EC2 instance based on `source-ami` | Optional | `ec2-user` |
| aws.region | [AWS region name](http://docs.aws.amazon.com/AWSEC2/latest/UserGuide/using-regions-availability-zones.html) | Optional | `ap-southeast-2` |
| aws.vpc_id | [VPC](https://docs.aws.amazon.com/AmazonVPC/latest/UserGuide/VPC_Subnets.html) ID where Packer creation will run from | Mandatory | |
| aws.subnet_id | [Subnet](https://docs.aws.amazon.com/AmazonVPC/latest/UserGuide/VPC_Subnets.html) ID where Packer creation will run from | Mandatory | |
| aws.source_ami | ID of the AMI used as the base of all component AMIs  | Mandatory | |
| aws.ami_users | A comma-separated-value string of AWS account IDs to share the created AMIs with. Empty or undefined indicates the created AMIs won't be shared. | Optional | |
| aws.snapshot_users | A comma-separated-value string of AWS account IDs to copy volumes from the shared AMI(s). Empty or undefined indicates the shared AMIs are not allow to be copied in any destination accounts. | Optional | |
| aws.temporary_security_group_source_cidr | A comma-separated-value string of IPv4 CIDR blocks to be authorised access to the instance, when packer is creating a temporary security group. | Optional | `0.0.0.0/0` |
| aws.iam_instance_profile | IAM Instance Profile name as set up in [AWS Resources](https://github.com/shinesolutions/packer-aem/blob/master/docs/aws-resources.md) | Mandatory | |
| aws.install_ssm_agent | Set to `true` when SSM agent must be installed | Optional | `true` |
| aws.install_cloudwatchlogs | Set to `true` when CloudWatch logs agent must be installed | Optional | `true` |
| aws.install_cloudwatchlogs_aem | Set to `true` when CloudWatch logs agent should be configured to stream AEM Author & Publish component logs to Cloudwatch | Optional | `true` |
| aws.install_cloudwatchlogs_httpd | Set to `true` when CloudWatch logs agent should be configured to stream AEM Dispatcher component logs to Cloudwatch | Optional | `true` |
| aws.install_cloudwatchlogs_java | Set to `true` when CloudWatch logs agent should be configured to stream AOC Java component logs to Cloudwatch | Optional | `true` |
| aws.install_cloudwatch_metric_agent | Set to `true` when [CloudWatch metric agent](https://docs.aws.amazon.com/AmazonCloudWatch/latest/monitoring/Install-CloudWatch-Agent.html) must be installed. If this is enabled, you must set your root device name to `/dev/xvda2` | Optional | `false` |
| aws.root_volume_size | The size of root volume in Gb, this is where the operating system and AEM installation reside | Optional | `20` |
| aws.data_volume_size | The size of data volume in Gb, this is where AEM repository resides | Optional | `75` |
| aws.tags | An array of `Key` and `Value` pairs for tagging AWS resources (e.g. EC2 instance, AMI, EBS volume) created by Packer AEM following your organisation's tagging standard | Optional | None |
| aws.certificate_arn | The ARN of the Certificate in either the [AWS Certificate Manager (ACM)](https://console.aws.amazon.com/acm/home) or IAM Server Certificate or an S3 key path to the certificate object.  Valid values are either `arn:aws:acm:...` or `arn:aws:iam:...`, `s3://...`, `http://...`, `https://...` or `file://...`| Mandatory | |
| aws.certificate_key_arn | The ARN of the secret containing TLS certificate's secret key in the [AWS Secrets Manager](https://console.aws.amazon.com/secretsmanager/home) or an S3 key path, http url, https url or file path to the certificate object. Valid values are either `arn:aws:secretsmanager:...`, `s3://...`, `http://...`, `https://...` or `file://...`| Optional | |
| aws.encryption.ebs_volume.enable | Boolean wether if EBS Volume encryption should be enabled or not. | Optional | `false`|
| aws.encryption.ebs_volume.kms_key_id | The user can define a KMS CMK id to encrypt the EBS Volume with a custom key rather than the default key. | Optional | `None`|
| aws.resources.stack_name | Appended string for Packer AEM Resources stack-name created by `make create-aws-resources`| Optional | `packer-aem-resources-stack`|
| aws.resources.s3_bucket | Name of bucket used by packer-aem to store artifacts, created by `make create-aws-resources` or the name of an existing bucket | Mandatory | `overwrite-me` |
| aws.resources.enable_secrets_manager | A `true` or `false` string value to indicate if AEM OpenCloud can provision AWS Secrets Manager resource, which is currently supported for storing TLS certificate's private key  | Optional | `true` |
| aws.resources.create_s3_bucket | A `true` or `false` boolean value to indicate if Packer-AEM create-aws-resources should provision an S3 Bucket for packer when baking AMIs | Optional | `true` |
| aws.resources.create_iam_packer_role | A `true` or `false` boolean value to indicate if Packer-AEM create-aws-resources should provision an IAM Role/InstanceProfile for packer when baking AMIs  | Optional | `true` |
| aws.aem_license | AWS Systems Manager parameter containing the multi-line AEM license content. Like the aem.keystore_password_parameter it is prefixed with / automatically meaning it becomes /aem-opencloud/stack_prefix/aem-license on consumption. Like Above it cannot have dots/periods in the parameter name. For more information please see the linked documentation in aem.keystore_password_parameter | Mandatory | |
