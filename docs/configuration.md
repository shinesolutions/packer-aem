Configuration
-------------

The following configurations are available for users to customise the creation process and the resulting machine images.

- AWS Tags
- Hieradata
- Packer Variables

AWS Tags
--------

AWS resources (e.g. EC2 instance, AMI, EBS volume) created by Packer AEM can be tagged following your organisation's tagging standard.

Create a YAML file which contains key value pairs for the tags in the following format:

```
Tags:
  - Key: Tag Name 1
    Value: Tag Value 1
  - Key: Tag Name 2
    Value: Tag Value 2
```

Check out the [example tags config file](https://github.com/shinesolutions/packer-aem/blob/master/examples/user-config/sandpit-tags.yaml)

Hieradata
---------

Provisioning parameters can be configured in a Hieradata YAML file.

| Name | Description |
|------|-------------|
| `config::params::timezone_region` | [Timezone region name as per tz database list](https://en.wikipedia.org/wiki/List_of_tz_database_time_zones#List) |
| `config::params::timezone_locality` | [Timezone locality name as per tz database list](https://en.wikipedia.org/wiki/List_of_tz_database_time_zones#List) |
| `config::params::aws_region` | [AWS region name](http://docs.aws.amazon.com/AWSEC2/latest/UserGuide/using-regions-availability-zones.html) |
| `config::params::aem_author_jvm_mem_opts` | AEM Author's memory-specific [JVM arguments](https://docs.oracle.com/cd/E22289_01/html/821-1274/configuring-the-default-jvm-and-java-arguments.html) |
| `config::params::aem_author_jvm_opts` | AEM Author's [JVM arguments](https://docs.oracle.com/cd/E22289_01/html/821-1274/configuring-the-default-jvm-and-java-arguments.html) |
| `config::params::aem_publish_jvm_mem_opts` | AEM Publish's memory-specific [JVM arguments](https://docs.oracle.com/cd/E22289_01/html/821-1274/configuring-the-default-jvm-and-java-arguments.html) |
| `config::params::aem_publish_jvm_opts` | AEM Publish's [JVM arguments](https://docs.oracle.com/cd/E22289_01/html/821-1274/configuring-the-default-jvm-and-java-arguments.html) |
| `config::params::aem_profile` | AEM Profile, check out the [list of available profiles](https://github.com/shinesolutions/puppet-aem-curator/blob/master/docs/aem-profiles-artifacts.md) |
| `config::params::aem_artifacts_base` | S3 Bucket path for storing AEM artifacts as set up in [AWS Resources](https://github.com/shinesolutions/packer-aem/blob/master/docs/aws-resources.md) |
| `config::params::aem_certs_base` | S3 Bucket path for storing TLS certificate as prepared in [AWS Resources](https://github.com/shinesolutions/packer-aem/blob/master/docs/aws-resources.md) |
| `config::params::aem_keystore_password` | [Java Keystore](https://www.digitalocean.com/community/tutorials/java-keytool-essentials-working-with-java-keystores) password used in AEM Author and Publish |

Check out the [example Hieradata config file](https://github.com/shinesolutions/packer-aem/blob/master/examples/user-config/sandpit-hieradata.yaml)

Packer Variables
----------------

AMI creation parameters can be configured in a Packer vars config file.

| Name | Description |
|------|-------------|
| `aws_user` | SSH username which Packer will use to connect to EC2 instance based on `source-ami` |
| `aws_region` | [AWS region name](http://docs.aws.amazon.com/AWSEC2/latest/UserGuide/using-regions-availability-zones.html) |
| `source_ami` | ID of the AMI used as the base of all component AMIs  |
| `iam_instance_profile` | IAM Instance Profile name as set up in [AWS Resources](https://github.com/shinesolutions/packer-aem/blob/master/docs/aws-resources.md) |
| `http_proxy` | [Web proxy server](https://en.wikipedia.org/wiki/Proxy_server) for http URLs, leave empty if Packer EC2 instances can directly connect to the Internet |
| `https_proxy` | [Web proxy server](https://en.wikipedia.org/wiki/Proxy_server) for https URLs, leave empty if Packer EC2 instances can directly connect to the Internet |

Check out the [example Packer Variables config file](https://github.com/shinesolutions/packer-aem/blob/master/examples/user-config/sandpit-packer-vars.yaml)
