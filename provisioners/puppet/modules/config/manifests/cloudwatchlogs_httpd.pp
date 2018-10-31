define config::cloudwatchlogs_httpd (
) {

  $httpd_log_dir = '/var/log/httpd'

  $httpd_apache_datetime_files = [ 'access_log', 'httpd-non-ssl_access.log', 'httpd-ssl_access_ssl.log' ]
  $httpd_unknown_datetime_files = [
    # These files contain formats not currently supported .e.g Mon, Tue, Wed
    'default_error.log', 'error_log', 'httpd-non-ssl_error.log', 'httpd-ssl_error.log',
    'dispatcher.log'
  ]

  $httpd_apache_datetime_files.each |$file| {
    cloudwatchlogs::log { "${httpd_log_dir}/${file}":
      datetime_format => '%d/%b/%Y:%H:%M:%S %z',
      notify          => Service[$service_name],
    }
  }
  $httpd_unknown_datetime_files.each |$file| {
    cloudwatchlogs::log { "${httpd_log_dir}/${file}":
      notify          => Service[$service_name],
    }
  }

}
