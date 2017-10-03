shared_examples "aem" do |role, port|

  aem_packages = {
    'cq-6.2.0-hotfix-11490': {
      :has_restart => false,
      :version     => '1.2',
    },
    'cq-6.2.0-hotfix-12785': {
      :has_restart => true,
      :version     => '7.0',
    },
    'aem-service-pkg': {
      :has_restart => false,
      :version     => '6.2.SP1',
    },
    'cq-6.2.0-sp1-cfp': {
      :has_restart => false,
      :version     => '3.0',
    },
    'cq-6.2.0-hotfix-15607': {
      :has_restart => false,
      :version     => '1.0',
    },
  }

  it { is_expected.to compile }
  it { is_expected.to contain_class('config') }
  it { is_expected.to contain_class('config::base') }
  it { is_expected.to contain_class('config::java') }
  it { is_expected.to contain_aem__instance('aem') }
  it { is_expected.to contain_aem_aem('Ensure login page is ready') }
  it { is_expected.to contain_aem_aem('Wait until login page is ready') }
  it { is_expected.to contain_aem_aem('Wait until aem health check is ok') }
  it { is_expected.to contain_exec('Manual delay to let AEM become ready') }
  it { is_expected.to contain_file('/etc/puppetlabs/puppet/aem.yaml') }
  it { is_expected.to contain_file('/tmp/aem_install_tmp') }

  logs = [
    'access.log', 'audit.log', 'auditlog.log', 'error.log',
    'history.log', 'request.log', 'stdout.log', 'upgrade.log',
  ]
  logs.each do |log|
    it { is_expected.to contain_cloudwatchlogs__log("/opt/aem/#{role}/crx-quickstart/logs/#{log}") }
  end

  it { is_expected.to contain_aem__crx__package('aem-healthcheck') }
  it { is_expected.to contain_archive('/tmp/shinesolutions/packer-aem/aem-healthcheck-content-1.3.3.zip') }

  aem_packages.each do |pkg_name, pkg|
    it { is_expected.to contain_config__aem_install_package(pkg_name) }

    it { is_expected.to contain_archive("/tmp/aem_install_tmp/#{pkg_name}-#{pkg[:version]}.zip") }
    it { is_expected.to contain_aem_package("Install #{pkg_name}") }
    it { is_expected.to contain_exec("Wait post install of #{pkg_name}") }

    if pkg[:has_restart]
      it { is_expected.to contain_aem_aem("Wait for login page before restart #{pkg_name}") }
      it { is_expected.to contain_aem_aem("Wait until aem health check is ok before restart #{pkg_name}") }
      it { is_expected.to contain_exec("Stop post install of #{pkg_name}") }
      it { is_expected.to contain_exec("Start post install of #{pkg_name}") }
      it { is_expected.to contain_exec("Wait post stop with #{pkg_name}") }
      it { is_expected.to contain_exec("Wait post start with #{pkg_name}") }
    end

    it { is_expected.to contain_aem_aem("Wait for login page post #{pkg_name}") }
    it { is_expected.to contain_aem_aem("Wait until aem health check is ok post #{pkg_name}") }
    it { is_expected.to contain_exec("Wait post login page for #{pkg_name}") }
  end

  files = [
    "/opt/aem/#{role}/aem-#{role}-#{port}.jar",
    "/opt/aem/#{role}/license.properties",
  ]

  files.each do |file|
    it { is_expected.to contain_archive(file) }
    it { is_expected.to contain_file(file) }
  end

  directories = [ '/opt/aem', "/opt/aem/#{role}" ]
  directories.each do |dir|
    it { is_expected.to contain_file(dir).with_ensure('directory') }
  end

  it { is_expected.to contain_file("/opt/aem/#{role}/crx-quickstart/ssl") }
  it { is_expected.to contain_archive('/tmp/aem_certs/aem.key') }
  it { is_expected.to contain_archive('/tmp/aem_certs/aem.cert') }
  it {
    is_expected.to contain_java_ks("cqse:/opt/aem/#{role}/crx-quickstart/ssl/aem.ks")
    .that_requires([
      'Archive[/tmp/aem_certs/aem.key]',
      'Archive[/tmp/aem_certs/aem.cert]',
    ])
  }

  included_classes = [
    'config',
    'config::base',
    'config::java',
    'config::aem',
    'config::aem_cleanup',
  ]
  included_classes.each do |cls|
    it { is_expected.to contain_class(cls) }
  end
  it { is_expected.to contain_exec('rm -f /opt/aem/aem-healthcheck-content-*.zip') }
end
