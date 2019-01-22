include ::config::base

include ::config::certs

include ::config::license

include aem_curator::install_java

include aem_curator::install_author

include aem_curator::install_publish

if $::config::base::install_cloudwatchlogs {
  config::cloudwatchlogs_aem { 'author: Setup CloudWatch for AEM Author':
    aem_id => 'author',
  }
  config::cloudwatchlogs_aem { 'publish: Setup CloudWatch for AEM Publish':
    aem_id => 'publish',
  }
  config::cloudwatchlogs_httpd { 'Setup CloudWatch for Dispatcher': }
}

include aem_curator::install_dispatcher

if $::config::base::install_collectd {
  config::collectd_jmx { 'Setup collectd-generic-jmx plugin': }
}
