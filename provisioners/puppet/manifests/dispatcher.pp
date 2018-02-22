include aem_curator::install_dispatcher

if $::config::base::install_cloudwatchlogs {
  include config::cloudwatchlogs_httpd
}
