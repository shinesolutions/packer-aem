Configuration
-------------

The following configurations are available for users to customise the creation process and the resulting machine images.

Check out the [example configuration files](https://github.com/shinesolutions/packer-aem/blob/master/examples/user-config/) as reference.

### Global configuration properties:

| Name | Description | Required? | Default |
|------|-------------|-----------|---------|
| platform_type | Platform type, currently only supports `aws` | Optional | `aws` |
| os_type | Operating System type, can be `rhel7`, `rhel6`, `centos7`, or `amazon-linux` | Optional | `rhel7` |
| http_proxy | [Web proxy server](https://en.wikipedia.org/wiki/Proxy_server) for http URLs, leave empty if Packer EC2 instances can directly connect to the Internet | Optional | Empty string |
| https_proxy | [Web proxy server](https://en.wikipedia.org/wiki/Proxy_server) for https URLs, leave empty if Packer EC2 instances can directly connect to the Internet | Optional | Empty string |
| no_proxy | A comma separated value of domain suffixes that you don't want to use with the web proxy. | Optional | Empty string |
| timezone.region | [Timezone region name as per tz database list](https://en.wikipedia.org/wiki/List_of_tz_database_time_zones#List) | Optional | `Australia` |
| timezone.locality | [Timezone locality name as per tz database list](https://en.wikipedia.org/wiki/List_of_tz_database_time_zones#List) | Optional | `Melbourne` |
| custom_image_provisioner.pre.timeout | The maximum duration (in seconds) allowed for Custom Image Provisioner pre step to run. | Optional | `3600` |
| custom_image_provisioner.post.timeout | The maximum duration (in seconds) allowed for Custom Image Provisioner post step to run. | Optional | `3600` |

### AEM configuration properties:

| Name | Description | Required? | Default |
|------|-------------|-----------|---------|
| aem.profile | AEM Profile, check out the [list of available profiles](https://github.com/shinesolutions/puppet-aem-curator/blob/master/docs/aem-profiles-artifacts.md) | Optional | `aem62_sp1_cfp9` |
| aem.keystore_password | [Java Keystore](https://www.digitalocean.com/community/tutorials/java-keytool-essentials-working-with-java-keystores) password used in AEM Author and Publish | Optional (but you should change it) | `changeit` |
| aem.author.jvm_mem_opts | AEM Author's memory-specific [JVM arguments](https://docs.oracle.com/cd/E22289_01/html/821-1274/configuring-the-default-jvm-and-java-arguments.html) | Optional | `-Xss4m -Xms4096m -Xmx8192m` |
| aem.author.jvm_opts | AEM Author's [JVM arguments](https://docs.oracle.com/cd/E22289_01/html/821-1274/configuring-the-default-jvm-and-java-arguments.html) | Optional |
| aem.author.start_opts | AEM Author's [start options](https://helpx.adobe.com/experience-manager/6-3/sites/deploying/using/custom-standalone-install.html#FurtheroptionsavailablefromtheQuickstartfile) | Optional | Empty string |
| aem.publish.jvm_mem_opts | AEM Publish's memory-specific [JVM arguments](https://docs.oracle.com/cd/E22289_01/html/821-1274/configuring-the-default-jvm-and-java-arguments.html) | Optional | `-Xss4m -Xms4096m -Xmx8192m` |
| aem.publish.jvm_opts | AEM Publish's [JVM arguments](https://docs.oracle.com/cd/E22289_01/html/821-1274/configuring-the-default-jvm-and-java-arguments.html) | Optional |
| aem.publish.start_opts | AEM Publish's [start options](https://helpx.adobe.com/experience-manager/6-3/sites/deploying/using/custom-standalone-install.html#FurtheroptionsavailablefromtheQuickstartfile) | Optional | Empty string |
| aem.dispatcher.version | AEM Dispatcher version, available version is documented on [Download Dispatcher Web Server Modules](https://www.adobeaemcloud.com/content/companies/public/adobe/dispatcher/dispatcher.html) page | Mandatory | `4.2.3` |
| aem.aem_artifacts_base | Source URL path of AEM artifacts, it could be `s3://...`, `http://...`, `https://...`, or `file://...`. In [AWS Resources](https://github.com/shinesolutions/packer-aem/blob/master/docs/aws-resources.md) case, it could be an S3 Bucket path, e.g. s3://somebucket/artifacts/ | Mandatory | |
| aem.aem_certs_base | Source URL path of TLS certificate, it could be `s3://...`, `http://...`, `https://...`, or `file://...`. In [AWS Resources](https://github.com/shinesolutions/packer-aem/blob/master/docs/aws-resources.md) case, it could be an S3 Bucket path, e.g. s3://somebucket/certs/ | Mandatory | |
| aem.enable_custom_image_provisioner | Set to `true` when Custom Image Provisioner pre and post steps will be executed , note: place `aem-custom-image-provisioner.tar.gz` artifact in `stage/custom/` directory | Optional | `false` |

### AWS platform type configuration properties:

| Name | Description | Required? | Default |
|------|-------------|-----------|---------|
| aws.user | SSH username which Packer will use to connect to EC2 instance based on `source-ami` | Optional | `ec2-user` |
| aws.region | [AWS region name](http://docs.aws.amazon.com/AWSEC2/latest/UserGuide/using-regions-availability-zones.html) | Optional | `ap-southeast-2` |
| aws.vpc_id | [VPC](https://docs.aws.amazon.com/AmazonVPC/latest/UserGuide/VPC_Subnets.html) ID where Packer creation will run from | Mandatory | |
| aws.subnet_id | [Subnet](https://docs.aws.amazon.com/AmazonVPC/latest/UserGuide/VPC_Subnets.html) ID where Packer creation will run from | Mandatory | |
| aws.source_ami | ID of the AMI used as the base of all component AMIs  | Mandatory | |
| aws.iam_instance_profile | IAM Instance Profile name as set up in [AWS Resources](https://github.com/shinesolutions/packer-aem/blob/master/docs/aws-resources.md) | Mandatory | |
| aws.install_ssm_agent | Set to `true` when SSM agent must be installed | Optional | `true` |
| aws.install_cloudwatchlogs | Set to `true` when CloudWatch logs agent must be installed | Optional | `true` |
| aws.root_volume_size | The size of root volume in Gb, this is where the operating system and AEM installation reside | Optional | `20` |
| aws.data_volume_size | The size of data volume in Gb, this is where AEM repository resides | Optional | `75` |
| aws.tags | An array of `Key` and `Value` pairs for tagging AWS resources (e.g. EC2 instance, AMI, EBS volume) created by Packer AEM following your organisation's tagging standard | Optional | None |
