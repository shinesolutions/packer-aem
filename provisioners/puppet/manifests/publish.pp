include ::config::base

include aem_curator::install_java

include aem_curator::install_publish

if $::config::base::install_cloudwatchlogs {
  config::cloudwatchlogs_aem { 'Setup CloudWatch for AEM Publish':
    aem_id => 'publish',
  }
}

if $::config::base::install_collectd {
  config::collectd_java { 'Setup collectd for Java': }
  collectd::plugin { ['generic-jmx']:
    ensure => present,
  }
}
