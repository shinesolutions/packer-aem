include ::config::base

include ::config::certs

include ::config::license

include aem_curator::install_java

include aem_curator::install_author

if $::config::base::install_cloudwatchlogs {
  config::cloudwatchlogs_aem { 'Setup CloudWatch for AEM Author':
    aem_id => 'author',
  }
}

if $::config::base::install_collectd {
  config::collectd_jmx { 'Setup collectd-generic-jmx plugin': }
}

if $::config::base::install_cloudwatch_metric_agent {
  config::cloudwatch_metric_agent { 'Setup Cloudwatch Metric Agent for AEM Author':
    disk_path   => [
      $::config::base::root_device_name,
      $::config::base::data_device_name
    ],
    autoscaling => false
  }
}

