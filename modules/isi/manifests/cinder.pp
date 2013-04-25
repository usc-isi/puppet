# == Class: isi::cinder
#
# Configure Cinder nodes.
#
# Change the value of $iam_cinder_master to true to enable cinder-api and
# cinder-scheduler services.
#
# === Parameters
#
# See isi::params for explanations of parameters pulled from that class.
# 
# [load_python_keystone   ] Set false if you're on same node as keystone. Optional. Default true, 
# [iam_cinder_master      ] Set true to configure API and scheduler. Optional. Default false.
# [bind_host              ] Network to listen on. Optional. Default '0.0.0.0' (all available).
# [keystone_auth_port     ] Port used for Keystone. Optional. Default '35357'.
# [keystone_auth_protocol ] Protocole used for Keystone. Optional. Default 'http'.
# [keystone_enabled       ] Use Keystone for authentciation if true. Optional. Default true.
# [lock_path              ] Directory for lock files. Optional. Default '/var/lib/cinder/tmp'.
# [logdir                 ] Directory for log files. Optional. Default '/var/log/cinder'.
# [package_ensure         ] Value for Puppet 'ensure' paramter. Optional. Default present.
# [rootwrap_config        ] Configuration file for cinder sudo. Optional. Default '/etc/cinder/rootwrap.conf'.
# [signing_dirname        ] Directory for temporary Keystone files. Optional. Default '/tmp/keystone-signing-cinder'.
# [state_path             ] Directory for Cinder state files. Optional. Default '/var/lib/cinder'.
# [create_openrc          ] Create an openrc file on node if true. Optional. Default false.
# [verbose                ] Use verbose logging if true. Optional. Default false.
#
# === Examples
#
# class {'isi::cinder':
#   stage                => last,
#   rpc_backend          => 'cinder.openstack.common.rpc.impl_kombu',
#   iam_cinder_master    => true,
#   load_python_keystone => false, # Because same node as keystone
#   require              => [ Class['isi::mysql'], Class['isi::keystone'] ],
# }
#
# === Authors
#
# Craig E. Ward <cward@isi.edu>
#
class isi::cinder (
  $rabbit_host             = $isi::params::rabbit_host,
  $rabbit_password         = $isi::params::rabbit_password,
  $rabbit_user             = $isi::params::rabbit_user,
  $db_host                 = $isi::params::db_host,
  $cinder_db_password      = $isi::params::cinder_db_password,
  $cinder_db_user          = $isi::params::cinder_db_user,
  $cinder_db_dbname        = $isi::params::cinder_db_dbname,
  $cinder_iscsi_ip_addr    = $isi::params::cinder_iscsi_ip_addr,
  $cinder_volume_group     = $isi::params::cinder_volume_group,
  $cinder_volumes_dir      = $isi::params::cinder_volumes_dir,
  $cinder_volumes_dir      = $isi::params::cinder_volumes_dir,
  $keystone_host_address   = $isi::params::keystone_host_address,
  $keystone_host_public    = $isi::params::keystone_host_public,
  $cinder_admin_password   = $isi::params::cinder_admin_password,
  $cinder_admin_tenant     = $isi::params::cinder_admin_tenant,
  $cinder_admin_user       = $isi::params::cinder_admin_user,
  $load_python_keystone    = true, # Set false if you're on same node as keystone
  $iam_cinder_master       = false,
  $bind_host               = '0.0.0.0',
  $keystone_admin_token    = $isi::params::keystone_admin_token,
  $keystone_auth_port      = '35357',
  $keystone_auth_protocol  = 'http',
  $keystone_enabled        = true,
  $lock_path               = '/var/lib/cinder/tmp',
  $logdir                  = '/var/log/cinder',
  $package_ensure          = present,
  $rootwrap_config         = '/etc/cinder/rootwrap.conf',
  $rpc_backend             = $isi::params::cinder_rpc_backend,
  $signing_dirname         = '/tmp/keystone-signing-cinder',
  $state_path              = '/var/lib/cinder',
  $create_openrc           = false,
  $verbose                 = false
  ) {

  class { 'cinder::base':
    rabbit_userid   => $rabbit_user,
    rabbit_host     => $rabbit_host,
    rabbit_password => $rabbit_password,
    sql_connection  => "mysql://${cinder_db_user}:${cinder_db_password}@${db_host}/${cinder_db_dbname}?charset=utf8",
    admin_user      => $cinder_admin_user,
    admin_password  => $cinder_admin_password,
    auth_host       => $keystone_host_public,
    auth_port       => $keystone_auth_port,
    auth_protocol   => $keystone_auth_protocol,
    signing_dirname => $signing_dirname,
    rootwrap_config => $rootwrap_config,
    volumes_dir     => $cinder_volumes_dir,
    state_path      => $state_path,
    lock_path       => $lock_path,
    logdir          => $logdir,
    rpc_backend     => $rpc_backend,
    verbose         => $verbose,
  }

  class { 'cinder::api':
    keystone_password      => $cinder_admin_password,
    keystone_enabled       => $keystone_enabled,
    keystone_tenant        => $cinder_admin_tenant,
    keystone_user          => $cinder_admin_user, 
    keystone_auth_host     => $keystone_host_public,
    keystone_auth_port     => $keystone_auth_port,
    keystone_auth_protocol => $keystone_auth_protocol,
    package_ensure         => $package_ensure,
    bind_host              => $bind_host,
    enabled                => $iam_cinder_master,
  }

  class { 'cinder::scheduler':
    package_ensure => $package_ensure,
    enabled        => $iam_cinder_master,
  }

  class { 'cinder::volume':
    package_ensure => $package_ensure,
    enabled        => true,
  }

  class { 'cinder::volume::iscsi':
    iscsi_ip_address => $cinder_iscsi_ip_addr,
    volume_group     => $cinder_volume_group,
    volumes_dir      => $cinder_volumes_dir,
  }

  if $load_python_keystone {

    Package['python-keystone'] -> Class['cinder::api']
  
    package { 'python-keystone':
      ensure => present,
    }
  }


  if $create_openrc {
    class { 'openstack::auth_file':
      admin_user           => $cinder_admin_user,
      admin_tenant         => $cinder_admin_tenant,
      controller_node      => $keystone_host_address,
      admin_password       => $cinder_admin_password,
      keystone_admin_token => $keystone_admin_token,
    }
    Class['openstack::auth_file'] -> Class['cinder::base']
  }


  }
