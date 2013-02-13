#
# Module for managing keystone config.
#
# == Parameters
#
#   [package_ensure] Desired ensure state of packages. Optional. Defaults to present.
#     accepts latest or specific versions.
#   [bind_host] Host that keystone binds to.
#   [bind_port]
#   [public_port]
#   [admin_port] Port that can be used for admin tasks.
#   [admin_token] Admin token that can be used to authenticate as a keystone
#     admin.
#   [compute_port] TODO
#   [log_verbose] Rather keystone should log at verbose level. Optional.
#     Defaults to False.
#   [log_debug] Rather keystone should log at debug level. Optional.
#     Defaults to False.
#   [use_syslog] Rather or not keystone should log to syslog. Optional.
#     Defaults to False.
#   [catalog_type]
#
# == Dependencies
#  None
#
# == Examples
#
#   class { 'keystone':
#     log_verbose => 'True',
#     admin_token => 'my_special_token',
#   }
#
# == Authors
#
#   Dan Bode dan@puppetlabs.com
#
# == Copyright
#
# Copyright 2012 Puppetlabs Inc, unless otherwise noted.
#
class keystone(
  $package_ensure = 'present',
  $bind_host      = '0.0.0.0',
  $public_port    = '5000',
  $admin_port     = '35357',
  $admin_token    = 'service_token',
#  $compute_port   = '3000',
  $compute_port   = '8774',
  $log_verbose    = 'False',
  $log_debug      = 'False',
  $use_syslog     = 'False',
  $catalog_type   = 'sql'
) {

  validate_re($catalog_type, 'template|sql')

  # TODO implement syslog features
  if ( $use_syslog != 'False') {
    fail('use syslog currently only accepts false')
  }

  include 'keystone::params'
  include 'concat::setup'

  package { 'keystone':
    name   => $::keystone::params::package_name,
    ensure => $package_ensure,
    notify => Exec['keystone-manage db_sync'],
  }

  group { 'keystone':
    ensure  => present,
    system  => true,
    require => Package['keystone'],
  }

  user { 'keystone':
    ensure  => 'present',
    gid     => 'keystone',
    system  => true,
    require => Package['keystone'],
  }

  file { '/etc/keystone':
    ensure  => directory,
    owner   => 'keystone',
    group   => 'keystone',
    mode    => 0755,
    require => Package['keystone']
  }

  concat { '/etc/keystone/keystone.conf':
    owner   => 'keystone',
    group   => 'keystone',
    mode    => '0600',
    require => Package['keystone'],
    notify  => [Service['keystone'], Exec['keystone-manage db_sync']],
  }

  # config sections
  keystone::config { 'DEFAULT':
    config => {
      'bind_host'    => $bind_host,
      'public_port'  => $public_port,
      'admin_port'   => $admin_port,
      'admin_token'  => $admin_token,
      'compute_port' => $compute_port,
      'log_verbose'  => $log_verbose,
      'log_debug'    => $log_debug,
      'use_syslog'   => $use_syslog
    },
    order  => '00',
  }

  keystone::config { 'identity':
    order  => '03',
  }

  if($catalog_type == 'template') {
    # if we are using a catalog, then I may want to manage the file
    keystone::config { 'template_catalog':
      order => '04',
    }
  } elsif($catalog_type == 'sql' ) {
    keystone::config { 'sql_catalog':
      order => '04',
    }
  }

  keystone::config { 'footer':
    order    => '99'
  }

  service { 'keystone':
    ensure     => running,
    name       => $::keystone::params::service_name,
    enable     => true,
    hasstatus  => true,
    hasrestart => true,
    provider   => $::keystone::params::service_provider,
    notify     => Exec['keystone-manage db_sync'],
  }

  # this probably needs to happen more often than just when the db is
  # created
  exec { 'keystone-manage db_sync':
    path        => '/usr/bin',
    refreshonly => false,
    subscribe   => Service['keystone'],
    notify      => Exec['initial_data'],
  }

  file { 'initial_data.sh':
    ensure  => present,
    path    => '/etc/keystone/initial_data.sh',
    mode    => '0750',
    owner   => 'root',
    group   => 'root',
# TODO: Nothing is processed at this time; perhaps should be.
#    content => template('keystone/initial_data.sh.erb'),
    source  => 'puppet:///modules/keystone/initial_data.sh',
    require => File['keystone_shell_functions'],
    notify  => Exec['initial_data'],
  }

  file {'keystone_shell_functions':
    ensure => present,
    path   => '/etc/keystone/keystone_shell_functions',
    owner  => 'root',
    group  => 'root',
    source => 'puppet:///modules/keystone/keystone_shell_functions',
    notify => File['initial_data.sh'],
  }

  exec { 'initial_data':
    command     => "/etc/keystone/initial_data.sh --token ${admin_token} --endpoint http://${bind_host}:${admin_port}/v2.0/",
    cwd         => '/etc/keystone',
# Script allows multiple invocations
    refreshonly => false,
#    refreshonly => true,
    require     => Exec['keystone-manage db_sync'],
    subscribe   => [ File['initial_data.sh'], File['keystone_shell_functions'] ],
  }
    
}
