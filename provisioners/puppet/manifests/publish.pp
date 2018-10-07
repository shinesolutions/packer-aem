include ::config::base

include aem_curator::install_java

include aem_curator::install_publish

if $::config::base::install_cloudwatchlogs {
  config::cloudwatchlogs_aem { 'Setup CloudWatch for AEM Publish':
    aem_id => 'publish',
  }
}

if $::config::base::install_collectd {
class { 'collectd::plugin::java':
  manage_package => true,
} -> class { 'collectd::plugin::genericjmx':
  manage_package => true,
}
}
