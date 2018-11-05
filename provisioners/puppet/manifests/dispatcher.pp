include ::config::base
include ::config::certs

include aem_curator::install_dispatcher

if $::config::base::install_cloudwatchlogs {
  config::cloudwatchlogs_httpd { 'Setup CloudWatch for Dispatcher': }
}
