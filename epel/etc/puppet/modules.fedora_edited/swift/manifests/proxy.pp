# Installs and configures the swift proxy node.
#
# [*Parameters*]
#
# [*allow_account_management*]
# [*account_autocreate*] Rather accounts should automatically be created.
#  I think this may be tempauth specific
# [*proxy_local_net_ip*] The address that the proxy will bind to.
#   Optional. Defaults to 0.0.0.0
# [*proxy_port*] Port that the swift proxy service will bind to.
#   Optional. Defaults to 11211
# [*auth_type*] - Type of authorization to use.
#  valid values are tempauth, swauth, and keystone.
#  Optional. Defaults to tempauth.
# [*package_ensure*] Ensure state of the swift proxy package.
#   Optional. Defaults to present.
#
# == sw auth specific configuration
# [*swauth_endpoint*]
# [*swauth_super_admin_user*]
#
# == Dependencies
#
#   Class['memcached']
#
# == Examples
#
# == Authors
#
#   Dan Bode dan@puppetlabs.com
#
# == Copyright
#
# Copyright 2011 Puppetlabs Inc, unless otherwise noted.
#
class swift::proxy(
  $allow_account_management = true,
  $account_autocreate = false,
  $proxy_local_net_ip = '0.0.0.0',
  $workers = 1,
  $proxy_port = '11211',
  $auth_type = 'tempauth',
  $swauth_endpoint = '127.0.0.1',
  $swauth_super_admin_key = 'swauthkey',
  $package_ensure = 'present',
  $keystone_auth_host = '127.0.0.1',
  $keystone_auth_port = '35357',
  $keystone_auth_protocol = 'http',
  $keystone_auth_uri = 'http://127.0.0.1:5000/',
  $keystone_admin_user = 'swift',
  $keystone_admin_password = 'SERVICE_PASSWORD',
  $keystone_admin_tenant_name = 'service',
  $keystone_signing_dir = '/etc/swift/keystone-signing'
) inherits swift {

  Class['memcached'] -> Class['swift::proxy']

  validate_re($auth_type, 'tempauth|swauth|keystone')

  package { 'openstack-swift-proxy':
    ensure => $package_ensure,
  }

  if($auth_type == 'swauth') {
    package { 'python-swauth':
      ensure  => $package_ensure,
      before  => Package['openstack-swift-proxy'],
    }
  }

  file { "/etc/swift/proxy-server.conf":
    ensure  => present,
    owner   => 'swift',
    group   => 'swift',
    mode    => 0660,
    content => template('swift/proxy-server.conf.erb'),
    require => Package['openstack-swift-proxy'],
  }

  file { $keystone_signing_dir:
    ensure  => directory,
    owner   => 'swift',
    group   => 'swift',
    mode    => 770,
    require => Package['openstack-swift-proxy']
  }

  service { 'openstack-swift-proxy':
    ensure    => running,
    enable    => true,
    subscribe => File['/etc/swift/proxy-server.conf'],
  }

}
