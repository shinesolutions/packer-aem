include ::config::base

include aem_curator::install_java

include aem_curator::install_author

if $::config::base::install_cloudwatchlogs {
  config::cloudwatchlogs { 'Setup CloudWatch for AEM Author':
    aem_role => 'author',
  }
}
