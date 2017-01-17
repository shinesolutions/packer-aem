stage { 'test':
  require => Stage['main']
}

package { 'nokogiri':
  ensure   => '1.6.8.1',
  provider => 'puppet_gem',
} ->
package { 'ruby_aem':
  ensure   => '1.0.6',
  provider => 'puppet_gem',
}

class { 'serverspec':
  stage             => 'test',
  component         => 'ruby_aem',
  staging_directory => '/tmp/packer-puppet-masterless-0',
  tries             => 15,
  try_sleep         => 3,
}
