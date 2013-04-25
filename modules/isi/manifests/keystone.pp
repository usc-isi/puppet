# == Class: isi::keystone
#
# Wrapper for openstack::keystone class. All of the values set from the
# isi::params class.
#
# === Parameters
#
# See isi::params for explanations of parameters.
#
# === Examples
#
#  class {'isi::keystone': }
#
# === Authors
#
# Craig E. Ward <cward@isi.edu>
#
class isi::keystone (
  $verbose                 = $isi::params::verbose,
  $db_type                 = $isi::params::db_type,
  $db_host                 = $isi::params::db_host,
  $keystone_db_password    = $isi::params::keystone_db_password,
  $keystone_db_dbname      = $isi::params::keystone_db_dbname,
  $keystone_db_user        = $isi::params::keystone_db_user,
  $keystone_admin_token    = $isi::params::keystone_admin_token,
  $keystone_admin_tenant   = $isi::params::keystone_admin_tenant,
  $admin_email             = $isi::params::admin_email,
  $keystone_admin_password = $isi::params::keystone_admin_password,
  $keystone_host_public    = $isi::params::keystone_host_public,
  $keystone_host_private   = $isi::params::keystone_host_private,
  $region                  = $isi::params::region,
  $glance_user_password    = $isi::params::glance_user_password,
  $nova_admin_password     = $isi::params::nova_admin_password,
  $cinder                  = $isi::params::cinder,
  $cinder_user_password    = $isi::params::cinder_admin_password,
  $quantum                 = $isi::params::quantum,
  $quantum_admin_password  = $isi::params::quantum_admin_password,
  $keystone                = $isi::params::keystone,
  $glance_host_public      = $isi::params::glance_host_public,
  $glance_host_internal    = $isi::params::glance_host_internal,
  $glance_host_public      = $isi::params::glance_host_public,
  $nova_host_public        = $isi::params::nova_host_public,
  $nova_host_internal      = $isi::params::nova_host_internal,
  $nova_host_public        = $isi::params::nova_host_public,
  $cinder_host_public      = $isi::params::cinder_host_public,
  $cinder_host_internal    = $isi::params::cinder_host_internal,
  $cinder_host_public      = $isi::params::cinder_host_public,
  $quantum_server_host     = $isi::params::quantum_server_host
  ) {

#  notify {"keystone_host_private=$keystone_host_private":}
  
####### KEYSTONE ###########
  class { 'openstack::keystone':
    verbose                  => $verbose,
    db_type                  => $db_type,
    db_host                  => $db_host,
    db_password              => $keystone_db_password,
    db_name                  => $keystone_db_dbname,
    db_user                  => $keystone_db_user,
    admin_token              => $keystone_admin_token,
    admin_tenant             => $keystone_admin_tenant,
    admin_email              => $admin_email,
    admin_password           => $keystone_admin_password,
    public_address           => $keystone_host_public,
    internal_address         => $keystone_host_private,
    admin_address            => $keystone_host_public,
    region                   => $region,
    glance_user_password     => $glance_user_password,
    nova_user_password       => $nova_admin_password,
    cinder                   => $cinder,
    cinder_user_password     => $cinder_user_password,
    quantum                  => $quantum,
    quantum_user_password    => $quantum_admin_password,
    enabled                  => $keystone,
    # Multi-node
    glance_public_address    => $glance_host_public,
    glance_internal_address  => $glance_host_internal,
    glance_admin_address     => $glance_host_public,
    nova_public_address      => $nova_host_public,
    nova_internal_address    => $nova_host_internal,
    nova_admin_address       => $nova_host_public,
    cinder_public_address    => $cinder_host_public,
    cinder_internal_address  => $cinder_host_internal,
    cinder_admin_address     => $cinder_host_public,
    quantum_public_address   => $quantum_server_host,
    quantum_internal_address => $quantum_server_host,
    quantum_admin_address    => $quantum_server_host,
  }

}
