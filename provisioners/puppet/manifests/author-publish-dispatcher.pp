include ::config::base

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
  class { 'collectd::plugin::java':
    manage_package => true,
  } -> class { 'collectd::plugin::genericjmx':
    manage_package => true,
  }
}
