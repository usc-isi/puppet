# Resources for a keystone contoller node

node 'bespin105.east.isi.edu' {

  # import 'defaults.pp'

  # Exec {
  #   path => [
               #     '/usr/local/sbin',
               #     '/usr/sbin',
               #     '/sbin',
               #     '/bin',
               #     '/usr/local/bin',
               #     '/usr/bin'],

  #   logoutput => true,
  # }

  # import 'vanilla-common.pp'
  
  # #$cinder_rabbit_host = '10.105.0.1' # DODCS-site specific
  # $rabbit_host     = '10.0.5.5'
  # $rabbit_password = 'dbsecrete'
  # $rabbit_user     = 'openstack_rabbit_user'

  #  import 'cinder-config.pp'
  # Configure cinder service on a node.

  #import 'cinder::params'

  class { 'cinder::base':
    rabbit_userid   => $rabbit_user, #'openstack_rabbit_user', #$cinder_rabbit_user,
    rabbit_host     => $rabbit_host, #'10.0.5.5', #$cinder_rabbit_host,
    rabbit_password => $rabbit_password, #'dbsecrete', #$cinder_rabbit_password,
    sql_connection  => "mysql://${cinder_db_user}:${cinder_db_password}@${db_host}/${cinder_db_dbname}?charset=utf8",
    admin_user      => $cinder_db_user,
    admin_password  => $cinder_db_password,
    auth_host       => $keystone_host_public,
    auth_port       => '35357',
    auth_protocol   => 'http',
    signing_dirname => '/tmp/keystone-signing-cinder',
    rootwrap_config => '/etc/cinder/rootwrap.conf',
    volumes_dir     => '/etc/cinder/volumes',
    state_path      => '/var/lib/cinder',
    lock_path       => '/var/lib/cinder/tmp',
    logdir          => '/var/log/cinder',
    rpc_backend     => 'cinder.openstack.common.rpc.impl_kombu',
    verbose         => $verbose,
  }

  class { 'cinder::api':
    keystone_password      => $keystone_admin_password,
    keystone_enabled       => true,
    keystone_tenant        => $keystone_admin_tenant,
    keystone_user          => $keystone_admin_user, 
    keystone_auth_host     => $keystone_host_public,
    keystone_auth_port     => '35357',
    keystone_auth_protocol => 'http',
    package_ensure         => 'present',
    bind_host              => '0.0.0.0',
  }

  class { 'cinder::scheduler':
    package_ensure => present,
  }
  
  class { 'openstack::auth_file':
    admin_user           => $keystone_admin_user,
    admin_tenant         => $keystone_admin_tenant,
    controller_node      => $keystone_host_address,
    admin_password       => $keystone_admin_password,
    keystone_admin_token => $keystone_admin_token,
  }

  Class['openstack::auth_file'] -> Class['cinder::base']
}
