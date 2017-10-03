# == Class: config::amz_linux_cis_benchmark
#
# A Puppet module to implement CIS Amazon Linux Benchmark v2.0.0 06-02-2016
#
# https://benchmarks.cisecurity.org/tools2/linux/CIS_Amazon_Linux_Benchmark_v2.0.0.pdf
#
# === Parameters
#
# [*modprobe_file*]
#   The file to write modprobe configuration to. Default is `/etc/modprobe.d/CIS.conf`
#
# === Authors
#
# James Sinclair <james.sinclair@shinesolutions.com>
#
# === Copyright
#
# Copyright © 2017	Shine Solutions Group, unless otherwise noted.
#
class config::amz_linux_cis_benchmark (
  $modprobe_file = '/etc/modprobe.d/CIS.conf',
) {
  File {
    owner => root,
    group => root,
  }

  # 1.1.1 Disable unused filesystems
  file { $modprobe_file:
    ensure => present,
    mode   => '0644',
  }
  $disabled_filesystems = [
    'cramfs', 'fat', 'freevxfs', 'hfs',
    'hfsplus', 'jffs2', 'squashfs', 'udf',
  ]
  $disabled_filesystems.each |$module| {
    file_line { "disable_${module}":
      ensure => present,
      line   => "install ${module} /bin/true",
      path   => $modprobe_file,
      match  => "^install ${module}",
    }
  }

  # 1.1.19 Disable Automounting
  service { 'autofs':
    ensure => stopped,
    enable => false,
  }

  # 1.4.1 Ensure permissions on bootloader config are configured
  file { '/boot/grub/menu.lst':
    mode => '0600',
  }

  # 1.4.2 Ensure authentication required for single user mode
  # 1.4.3 Ensure interactive boot is not enabled
  file { '/etc/sysconfig/init':
    ensure => present,
    mode   => '0644',
  }
  $init_config_settings = [
    [ 'SINGLE', '/sbin/nologin' ],
    [ 'PROMPT', 'no' ],
  ]
  $init_config_settings.each |$setting| {
    file_line { "init_${setting[0]}":
      ensure => present,
      line   => "${setting[0]}=${setting[1]}",
      path   => '/etc/sysconfig/init',
      match  => "^${setting[0]}=",
    }
  }

  # 1.5.1 Ensure core dumps are restricted
  limits::limits { '*/core':
    both => 0,
  }
  sysctl { 'defaults':
    prefix => '00',
    source => "puppet:///modules/${module_name}/default-sysctl-amz-linux.conf",
  }
  sysctl { 'fs.suid_dumpable':
    value => 0,
  }

  # 1.5.3 Ensure address space layout randomization (ASLR) is enabled
  sysctl { 'kernel.randomize_va_space':
    value => 2,
  }

  # 1.5.4 Ensure prelink is disabled
  package { 'prelink':
    ensure => absent,
  }

  # 2.1 inetd Services
  $disabled_inetd_services = [
    'chargen', 'daytime', 'discard', 'echo', 'rsh', 'rsync',
    'talk', 'telnet', 'tftp', 'time', 'xinetd',
  ]
  service { $disabled_inetd_services:
    ensure => stopped,
    enable => false,
  }

  # 2.2.2 Ensure X Window System is not installed
  $x11_packages = [
    'xorg-x11-apps', 'xorg-x11-drv-evdev', 'xorg-x11-drv-evdev-devel',
    'xorg-x11-drv-vesa', 'xorg-x11-drv-void', 'xorg-x11-fonts-100dpi',
    'xorg-x11-fonts-75dpi', 'xorg-x11-fonts-cyrillic', 'xorg-x11-fonts-ethiopic',
    'xorg-x11-fonts-ISO8859-1-100dpi', 'xorg-x11-fonts-ISO8859-14-100dpi',
    'xorg-x11-fonts-ISO8859-14-75dpi', 'xorg-x11-fonts-ISO8859-15-100dpi',
    'xorg-x11-fonts-ISO8859-15-75dpi', 'xorg-x11-fonts-ISO8859-1-75dpi',
    'xorg-x11-fonts-ISO8859-2-100dpi', 'xorg-x11-fonts-ISO8859-2-75dpi',
    'xorg-x11-fonts-ISO8859-9-100dpi', 'xorg-x11-fonts-ISO8859-9-75dpi',
    'xorg-x11-fonts-misc', 'xorg-x11-proto-devel', 'xorg-x11-resutils',
    'xorg-x11-server-common', 'xorg-x11-server-devel', 'xorg-x11-server-source',
    'xorg-x11-server-utils', 'xorg-x11-server-Xdmx', 'xorg-x11-server-Xephyr',
    'xorg-x11-server-Xnest', 'xorg-x11-server-Xorg', 'xorg-x11-server-Xvfb',
    'xorg-x11-util-macros', 'xorg-x11-utils', 'xorg-x11-xauth',
    'xorg-x11-xbitmaps', 'xorg-x11-xdm', 'xorg-x11-xinit', 'xorg-x11-xkb-extras',
    'xorg-x11-xkb-utils', 'xorg-x11-xkb-utils-devel', 'xorg-x11-xtrans-devel',
  ]
  # We're not disabling the following packages because they're needed for Java.
  # xorg-x11-fonts-Type1
  # xorg-x11-font-utils
  package { $x11_packages:
    ensure => absent,
  }

  # 2.2.[3-9,11-14,16] Ensure XXX is not enabled
  $disabled_services = [
    'avahi-daemon', 'cups', 'dhcpd', 'dovecot', 'named', 'nfs',
    'rpcbind', 'slapd', 'smb', 'snmpd', 'squid', 'vsftpd', 'ypserv',
  ]
  service { $disabled_services:
    ensure => stopped,
    enable => false,
  }

  # 2.3 Service Clients
  $disabled_clients = [ 'openldap-clients', 'rsh', 'talk', 'telnet', 'ypbind', ]
  package { $disabled_clients:
    ensure => absent,
  }

  # 3.1 Network Parameters (Host Only)
  # 3.2 Network Parameters (Host and Router)
  $disabled_net_sysctls = [
    # 3.1
    'net.ipv4.ip_forward',
    'net.ipv4.conf.all.send_redirects',
    'net.ipv4.conf.default.send_redirects',
    # 3.2
    'net.ipv4.conf.all.accept_source_route',
    'net.ipv4.conf.default.accept_source_route',
    'net.ipv4.conf.all.accept_redirects',
    'net.ipv4.conf.default.accept_redirects',
    'net.ipv4.conf.all.secure_redirects',
    'net.ipv4.conf.default.secure_redirects',
  ]
  sysctl { $disabled_net_sysctls:
    value => 0,
  }
  $enabled_net_sysctls = [
    'net.ipv4.conf.all.log_martians',
    'net.ipv4.conf.default.log_martians',
    'net.ipv4.icmp_echo_ignore_broadcasts',
    'net.ipv4.icmp_ignore_bogus_error_responses',
    'net.ipv4.conf.all.rp_filter',
    'net.ipv4.conf.default.rp_filter',
    'net.ipv4.tcp_syncookies',
  ]
  sysctl { $enabled_net_sysctls:
    value => 1,
  }
  # 3.3 IPv6
  $disabled_ipv6_sysctls = [
    # These are all unknown keys when the ipv6 module is disabled.
    #'net.ipv6.conf.all.accept_ra',
    #'net.ipv6.conf.default.accept_ra',
    #'net.ipv6.conf.all.accept_redirect',
    #'net.ipv6.conf.default.accept_redirect',
  ]
  sysctl { $disabled_ipv6_sysctls:
    value => 0,
  }
  file_line { 'disable_ipv6':
    ensure => present,
    line   => 'options ipv6 disable=1',
    path   => $modprobe_file,
    match  => '^options ipv6 ',
  }

  # 3.4 TCP Wrappers
  class { '::tcpwrappers': }
  $private_cidrs = [
    '10.0.0.0/8', '172.16.0.0/12', '192.168.0.0/16',
  ]
  tcpwrappers::allow { $private_cidrs: }
  tcpwrappers::deny { 'ALL': }

  # 3.5 Uncommon Network Protocols
  $disabled_protocols = [
    'dccp', 'sctp', 'rds', 'tipc',
  ]
  $disabled_protocols.each |$protocol| {
    file_line { "disable_${protocol}":
      ensure => present,
      line   => "install ${protocol} /bin/true",
      path   => $modprobe_file,
      match  => "^install ${protocol}",
    }
  }

  # 3.6.1 Ensure iptables is installed
  package { 'iptables':
    ensure => present,
  }

  # 5.1.1 Ensure cron daemon is enabled
  service { 'crond':
    ensure => running,
    enable => true,
  }

  # 5.1.2 Ensure permissions on /etc/crontab are configured
  file { '/etc/crontab':
    mode => '0600',
  }

  # 5.1.3-6 Ensure permissions on cron directories are configured
  $crontab_directories = [
    '/etc/cron.daily',
    '/etc/cron.hourly',
    '/etc/cron.monthly',
    '/etc/cron.weekly',
    '/etc/cron.d',
  ]
  $crontab_directories.each |$directory| {
    file { $directory:
      ensure => directory,
      mode   => '0700',
    }
  }

  # 5.2.1 Ensure permissions on /etc/ssh/sshd_config are configured
  file { '/etc/ssh/sshd_config':
    ensure => present,
    mode   => '0600',
  }

  # 5.2.2-14 SSH Settings
  $sshd_ciphers = [
    'aes256-ctr',
    'aes192-ctr',
    'aes128-ctr',
  ]
  $sshd_macs = [
    'hmac-sha2-512-etm@openssh.com',
    'hmac-sha2-256-etm@openssh.com',
    'umac-128-etm@openssh.com',
    'hmac-sha2-512',
    'hmac-sha2-256',
    'umac-128@openssh.com',
  ]
  $sshd_config_settings = [
    [ 'Protocol',                '2' ],
    [ 'LogLevel',                'INFO' ],
    [ 'X11Forwarding',           'no' ],
    [ 'MaxAuthTries',            '4' ],
    [ 'IgnoreRhosts',            'yes' ],
    [ 'HostbasedAuthentication', 'no' ],
    [ 'PermitRootLogin',         'no' ],
    [ 'PermitEmptyPasswords',    'no' ],
    [ 'PermitUserEnvironment',   'no' ],
    [ 'Ciphers',                 $sshd_ciphers.join(',') ],
    [ 'MACs',                    $sshd_macs.join(',') ],
    [ 'ClientAliveInterval',     '0' ],
    [ 'ClientAliveCountMax',     '0' ],
    [ 'LoginGraceTime',          '60' ],
  ]
  $sshd_config_settings.each |$setting| {
    file_line { "sshd_${setting[0]}":
      ensure => present,
      line   => "${setting[0]} ${setting[1]}",
      path   => '/etc/ssh/sshd_config',
      match  => "^${setting[0]} ",
    }
  }

  # 6.1.2-9 System file permissions
  $system_file_permissions = [
    [ '/etc/passwd',   '0644' ],
    [ '/etc/shadow',   '0000' ],
    [ '/etc/group',    '0644' ],
    [ '/etc/gshadow',  '0000' ],
    [ '/etc/passwd-',  '0600' ],
    [ '/etc/shadow-',  '0600' ],
    [ '/etc/group-',   '0600' ],
    [ '/etc/gshadow-', '0600' ],
  ]
  $system_file_permissions.each |$file| {
    file { $file[0]:
      mode => $file[1],
    }
  }
}
