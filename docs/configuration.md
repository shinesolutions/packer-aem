Configuration
-------------

The following configurations are available for users to customise the creation process and the resulting machine images.

Check out the [example configuration file](https://github.com/shinesolutions/packer-aem/blob/master/examples/user-config/sandpit.yaml) as a reference.

| Name | Description |
|------|-------------|
| os_type | Operating System type, can be `rhel7`, `rhel6`, or `amazon-linux` |
| http_proxy | [Web proxy server](https://en.wikipedia.org/wiki/Proxy_server) for http URLs, leave empty if Packer EC2 instances can directly connect to the Internet |
| https_proxy | [Web proxy server](https://en.wikipedia.org/wiki/Proxy_server) for https URLs, leave empty if Packer EC2 instances can directly connect to the Internet |
| no_proxy | A comma separated value of domain suffixes that you don't want to use with the web proxy. |
| timezone.region | [Timezone region name as per tz database list](https://en.wikipedia.org/wiki/List_of_tz_database_time_zones#List) |
| timezone.locality | [Timezone locality name as per tz database list](https://en.wikipedia.org/wiki/List_of_tz_database_time_zones#List) |
| aws.user | SSH username which Packer will use to connect to EC2 instance based on `source-ami` |
| aws.region | [AWS region name](http://docs.aws.amazon.com/AWSEC2/latest/UserGuide/using-regions-availability-zones.html) |
| aws.vpc_id | [VPC](https://docs.aws.amazon.com/AmazonVPC/latest/UserGuide/VPC_Subnets.html) ID where Packer creation will run from |
| aws.subnet_id | [Subnet](https://docs.aws.amazon.com/AmazonVPC/latest/UserGuide/VPC_Subnets.html) ID where Packer creation will run from |
| aws.source_ami | ID of the AMI used as the base of all component AMIs  |
| aws.iam_instance_profile | IAM Instance Profile name as set up in [AWS Resources](https://github.com/shinesolutions/packer-aem/blob/master/docs/aws-resources.md) |
| aws.aem_artifacts_base | S3 Bucket path for storing AEM artifacts as set up in [AWS Resources](https://github.com/shinesolutions/packer-aem/blob/master/docs/aws-resources.md) |
| aws.aem_certs_base | S3 Bucket path for storing TLS certificate as prepared in [AWS Resources](https://github.com/shinesolutions/packer-aem/blob/master/docs/aws-resources.md) |
| aws.tags | An array of `Key` and `Value` pairs for tagging AWS resources (e.g. EC2 instance, AMI, EBS volume) created by Packer AEM following your organisation's tagging standard |
| aem.profile | AEM Profile, check out the [list of available profiles](https://github.com/shinesolutions/puppet-aem-curator/blob/master/docs/aem-profiles-artifacts.md) |
| aem.keystore_password | [Java Keystore](https://www.digitalocean.com/community/tutorials/java-keytool-essentials-working-with-java-keystores) password used in AEM Author and Publish |
| aem.author.jvm_mem_opts | AEM Author's memory-specific [JVM arguments](https://docs.oracle.com/cd/E22289_01/html/821-1274/configuring-the-default-jvm-and-java-arguments.html) |
| aem.author.jvm_opts | AEM Author's [JVM arguments](https://docs.oracle.com/cd/E22289_01/html/821-1274/configuring-the-default-jvm-and-java-arguments.html) |
| aem.publish.jvm_mem_opts | AEM Publish's memory-specific [JVM arguments](https://docs.oracle.com/cd/E22289_01/html/821-1274/configuring-the-default-jvm-and-java-arguments.html) |
| aem.publish.jvm_opts | AEM Publish's [JVM arguments](https://docs.oracle.com/cd/E22289_01/html/821-1274/configuring-the-default-jvm-and-java-arguments.html) |
| aem.dispatcher.version | AEM Dispatcher version, available version is documented on [Download Dispatcher Web Server Modules](https://www.adobeaemcloud.com/content/companies/public/adobe/dispatcher/dispatcher.html) page |
