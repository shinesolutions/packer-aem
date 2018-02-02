include ::config::base

include aem_curator::install_java

include aem_curator::install_author

include aem_curator::install_publish

if $::config::base::install_cloudwatchlogs {
  config::cloudwatchlogs { 'Setup CloudWatch for AEM Author':
    aem_role => 'author',
  }
  config::cloudwatchlogs { 'Setup CloudWatch for AEM Publish':
    aem_role => 'publish',
  }
}

include aem_curator::install_dispatcher
