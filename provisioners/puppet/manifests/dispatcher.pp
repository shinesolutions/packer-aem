include ::config::base
include ::config::certs

include aem_curator::install_dispatcher

if $::config::base::install_cloudwatchlogs {
  config::cloudwatchlogs_httpd { 'Setup CloudWatch for Dispatcher': }
}

if $::config::base::install_cloudwatch_metric_agent {
  config::cloudwatch_metric_agent { 'Setup Cloudwatch Metric Agent for Dispatcher':
    disk_path => [
      $::config::base::root_device_name,
      $::config::base::data_device_name
    ]
  }
}

