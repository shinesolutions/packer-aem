define config::cloudwatch_metric_agent (
  $disk_path, $autoscaling=true
) {
  class { '::cloudwatch':
      enable_mem_util        => true,
      enable_mem_used        => true,
      enable_disk_space_util => true,
      enable_disk_space_used => true,
      auto_scaling           => $autoscaling,
      cron_min               => "*",
      disk_path              => $disk_path,
    }

}
