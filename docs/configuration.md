Configuration
-------------

The following configurations

- AWS Tags
- Hieradata
- Packer Variables

AWS Tags
--------

AWS resources created by Packer AEM can be tagged following your organisation's tagging standard.

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

Provisioning parameters can be configured by the users in a Hieradata YAML file.

| Name | Description |
|------|-------------|
| `config::params::timezone_region` | [Timezone region name as per tz database list](https://en.wikipedia.org/wiki/List_of_tz_database_time_zones#List) |
| `config::params::timezone_locality` | [Timezone region name as per tz database list](https://en.wikipedia.org/wiki/List_of_tz_database_time_zones#List) |
| `config::params::aws_region` | [AWS region name](http://docs.aws.amazon.com/AWSEC2/latest/UserGuide/using-regions-availability-zones.html) |
| `config::params::aem_author_jvm_opts` | AEM Author's JVM arguments](https://docs.oracle.com/cd/E22289_01/html/821-1274/configuring-the-default-jvm-and-java-arguments.html) |
| `config::params::aem_publish_jvm_opts` | AEM Publish's JVM arguments](https://docs.oracle.com/cd/E22289_01/html/821-1274/configuring-the-default-jvm-and-java-arguments.html) |
| `config::params::aem_profile` | AEM Profile, check out the [list of available profiles](https://github.com/shinesolutions/puppet-aem-curator/blob/master/docs/aem-profiles-artifacts.md) |
| `config::params::aem_artifacts_base` | S3 Bucket path for storing AEM artifacts as prepared in [AWS Resources](https://github.com/shinesolutions/packer-aem/blob/master/docs/aws-resources.md) |
| `config::params::aem_certs_base` | S3 Bucket path for storing TLS certificate as prepared in [AWS Resources](https://github.com/shinesolutions/packer-aem/blob/master/docs/aws-resources.md) |
| `config::params::aem_keystore_password` | [Java Keystore](https://www.digitalocean.com/community/tutorials/java-keytool-essentials-working-with-java-keystores) password used in AEM Author and Publish |

Check out the [example Hieradata config file](https://github.com/shinesolutions/packer-aem/blob/master/examples/user-config/sandpit-hieradata.yaml)

Packer Variables
----------------



Check out the [example Packer Variables config file](https://github.com/shinesolutions/packer-aem/blob/master/examples/user-config/sandpit-packer-vars.yaml)
