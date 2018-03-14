include ::config::base

include aem_curator::install_java

include aem_curator::install_author

include aem_curator::install_publish

if $::config::base::install_cloudwatchlogs {
  config::cloudwatchlogs_aem { 'Setup CloudWatch for AEM Author':
    aem_role => 'author',
  }
  config::cloudwatchlogs_aem { 'Setup CloudWatch for AEM Publish':
    aem_role => 'publish',
  }
  config::cloudwatchlogs_httpd { 'Setup CloudWatch for Dispatcher': }
}

include aem_curator::install_dispatcher
