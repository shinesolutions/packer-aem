require 'spec_helper'
describe 'config::amz_linux_cis_benchmark' do
  modprobe_file = '/etc/modprobe.d/CIS.conf'
  context 'with defaults for all parameters' do
    it { is_expected.to compile }

    it { is_expected.to contain_class('config::amz_linux_cis_benchmark') }
    it { is_expected.to contain_package('iptables').with_ensure('present') }

    it {
      is_expected.to contain_service('crond')
      .with_ensure('running')
      .with_enable(true)
    }

    it {
      is_expected.to contain_file_line("disable_ipv6")
      .with_path(modprobe_file)
      .with_line('options ipv6 disable=1')
    }

    it { is_expected.to contain_file('/boot/grub/menu.lst').with_mode('0600') }
    it { is_expected.to contain_file('/etc/ssh/sshd_config').with_mode('0600') }
    it { is_expected.to contain_file('/etc/modprobe.d/CIS.conf').with_mode('0644') }
    it { is_expected.to contain_file('/etc/sysconfig/init').with_mode('0644') }

    disabled_filesystems = [
      'cramfs', 'fat', 'freevxfs', 'hfs',
      'hfsplus', 'jffs2', 'squashfs', 'udf',
    ]
    disabled_protocols = [
      'dccp', 'sctp', 'rds', 'tipc',
    ]
    (disabled_filesystems + disabled_protocols).each do |mod|
      it {
        is_expected.to contain_file_line("disable_#{mod}")
        .with_path(modprobe_file)
        .with_line("install #{mod} /bin/true")
      }
    end

    disabled_services = [
      'autofs', 'avahi-daemon', 'cups', 'dhcpd', 'dovecot', 'named', 'nfs',
      'rpcbind', 'slapd', 'smb', 'snmpd', 'squid', 'vsftpd', 'ypserv',
    ]
    disabled_inetd_services = [
      'chargen', 'daytime', 'discard', 'echo', 'rsh', 'rsync', 'talk',
      'telnet', 'tftp', 'time', 'xinetd',
    ]
    (disabled_services + disabled_inetd_services).each do |svc|
      it {
        is_expected.to contain_service(svc)
        .with_ensure('stopped')
        .with_enable(false)
      }
    end

    init_config_settings = {
      'SINGLE': '/sbin/nologin',
      'PROMPT': 'no',
    }
    init_config_settings.each do |setting, value|
      it {
        is_expected.to contain_file_line("init_#{setting}")
        .with_ensure('present')
        .with_line("#{setting}=#{value}")
        .with_path('/etc/sysconfig/init')
      }
    end

    absent_packages = [
      'prelink',
    ]
    disabled_clients = [
      'openldap-clients', 'rsh', 'talk', 'telnet', 'ypbind',
    ]
    x11_packages = [
      'xorg-x11-apps', 'xorg-x11-drv-evdev', 'xorg-x11-drv-evdev-devel',
      'xorg-x11-drv-vesa', 'xorg-x11-drv-void', 'xorg-x11-fonts-100dpi',
      'xorg-x11-fonts-75dpi', 'xorg-x11-fonts-cyrillic',
      'xorg-x11-fonts-ethiopic', 'xorg-x11-fonts-ISO8859-1-100dpi',
      'xorg-x11-fonts-ISO8859-14-100dpi', 'xorg-x11-fonts-ISO8859-14-75dpi',
      'xorg-x11-fonts-ISO8859-15-100dpi', 'xorg-x11-fonts-ISO8859-15-75dpi',
      'xorg-x11-fonts-ISO8859-1-75dpi', 'xorg-x11-fonts-ISO8859-2-100dpi',
      'xorg-x11-fonts-ISO8859-2-75dpi', 'xorg-x11-fonts-ISO8859-9-100dpi',
      'xorg-x11-fonts-ISO8859-9-75dpi', 'xorg-x11-fonts-misc',
      'xorg-x11-proto-devel', 'xorg-x11-resutils', 'xorg-x11-server-common',
      'xorg-x11-server-devel', 'xorg-x11-server-source',
      'xorg-x11-server-utils', 'xorg-x11-server-Xdmx',
      'xorg-x11-server-Xephyr', 'xorg-x11-server-Xnest',
      'xorg-x11-server-Xorg', 'xorg-x11-server-Xvfb', 'xorg-x11-util-macros',
      'xorg-x11-utils', 'xorg-x11-xauth', 'xorg-x11-xbitmaps', 'xorg-x11-xdm',
      'xorg-x11-xinit', 'xorg-x11-xkb-extras', 'xorg-x11-xkb-utils',
      'xorg-x11-xkb-utils-devel', 'xorg-x11-xtrans-devel',
    ]
    (absent_packages + disabled_clients + x11_packages).each do |pkg|
      it { is_expected.to contain_package(pkg) .with_ensure('absent') }
    end

    disabled_sysctls = [
      'fs.suid_dumpable',
    ]
    disabled_net_sysctls = [
      'net.ipv4.ip_forward',
      'net.ipv4.conf.all.send_redirects',
      'net.ipv4.conf.default.send_redirects',
      'net.ipv4.conf.all.accept_source_route',
      'net.ipv4.conf.default.accept_source_route',
      'net.ipv4.conf.all.accept_redirects',
      'net.ipv4.conf.default.accept_redirects',
      'net.ipv4.conf.all.secure_redirects',
      'net.ipv4.conf.default.secure_redirects',
    ]
    (disabled_sysctls + disabled_net_sysctls).each do |sysctl|
      it { is_expected.to contain_sysctl(sysctl).with_value(0) }
    end

    enabled_net_sysctls = [
      'net.ipv4.conf.all.log_martians',
      'net.ipv4.conf.default.log_martians',
      'net.ipv4.icmp_echo_ignore_broadcasts',
      'net.ipv4.icmp_ignore_bogus_error_responses',
      'net.ipv4.conf.all.rp_filter',
      'net.ipv4.conf.default.rp_filter',
      'net.ipv4.tcp_syncookies',
    ]
    enabled_net_sysctls.each do |sysctl|
      it { is_expected.to contain_sysctl(sysctl).with_value(1) }
    end

    it { is_expected.to contain_sysctl('kernel.randomize_va_space').with_value(2) }
    it {
      is_expected.to contain_sysctl('defaults')
      .with_prefix('00')
      .with_source('puppet:///modules/config/default-sysctl-amz-linux.conf')
    }

    it { is_expected.to contain_file('/etc/crontab').with_mode('0600') }

    crontab_directories = [
      'daily',
      'hourly',
      'monthly',
      'weekly',
      'd',
    ]
    crontab_directories.each do |dir|
      it {
        is_expected.to contain_file("/etc/cron.#{dir}")
        .with_ensure('directory')
        .with_mode('0700')
      }
    end

    system_file_permissions = {
      '0644': [ 'passwd', 'group', ],
      '0000': [ 'shadow', 'gshadow', ],
    }
    system_file_permissions.each do |mode, files|
      files.each do |file|
        it { is_expected.to contain_file("/etc/#{file}").with_mode(mode) }
        it { is_expected.to contain_file("/etc/#{file}-").with_mode('0600') }
      end
    end

    sshd_ciphers = [ 'aes256-ctr', 'aes192-ctr', 'aes128-ctr', ]
    sshd_macs = [
      'hmac-sha2-512-etm@openssh.com',
      'hmac-sha2-256-etm@openssh.com',
      'umac-128-etm@openssh.com',
      'hmac-sha2-512',
      'hmac-sha2-256',
      'umac-128@openssh.com',
    ]
    sshd_config_settings = {
      'Protocol':                '2',
      'LogLevel':                'INFO',
      'X11Forwarding':           'no',
      'MaxAuthTries':            '4',
      'IgnoreRhosts':            'yes',
      'HostbasedAuthentication': 'no',
      'PermitRootLogin':         'no',
      'PermitEmptyPasswords':    'no',
      'PermitUserEnvironment':   'no',
      'Ciphers':                 sshd_ciphers.join(','),
      'MACs':                    sshd_macs.join(','),
      'ClientAliveInterval':     '0',
      'ClientAliveCountMax':     '0',
      'LoginGraceTime':          '60',
    }
    sshd_config_settings.each do |setting, value|
      it {
        is_expected.to contain_file_line("sshd_#{setting}")
        .with_ensure('present')
        .with_line("#{setting} #{value}")
        .with_path('/etc/ssh/sshd_config')
      }
    end

    allowed_cidrs = [ '10.0.0.0/8', '172.16.0.0/12', '192.168.0.0/16', ]
    allowed_cidrs.each do |cidr|
      it { is_expected.to contain_tcpwrappers__allow(cidr) }
    end
    it { is_expected.to contain_tcpwrappers__deny('ALL') }

    it { is_expected.to contain_limits__limits('*/core').with_both(0) }
  end
end
