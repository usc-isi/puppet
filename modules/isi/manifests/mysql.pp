# == Class: isi::mysql
#
# Wrapper for openstack::db::mysql class. All of the values set from the
# isi::params class.
#
# === Parameters
#
# See isi::params for explanations of parameters.
#
# === Examples
#
#  class {'isi::mysql': }
#
# === Authors
#
# Craig E. Ward <cward@isi.edu>
#
class isi::mysql (
  $manage_mysql_server    = $isi::params::manage_mysql_server,
  $mysql_root_password    = $isi::params::mysql_root_password,
  $mysql_bind_address     = $isi::params::mysql_bind_address,
  $mysql_account_security = $isi::params::mysql_account_security,
  $keystone_db_user       = $isi::params::keystone_db_user,
  $keystone_db_password   = $isi::params::keystone_db_password,
  $keystone_db_dbname     = $isi::params::keystone_db_dbname,
  $glance_db_user         = $isi::params::glance_db_user,
  $glance_db_password     = $isi::params::glance_db_password,
  $glance_db_dbname       = $isi::params::glance_db_dbname,
  $nova_db_user           = $isi::params::nova_db_user,
  $nova_db_password       = $isi::params::nova_db_password,
  $nova_db_dbname         = $isi::params::nova_db_dbname,
  $cinder                 = $isi::params::cinder,
  $cinder_db_user         = $isi::params::cinder_db_user,
  $cinder_db_password     = $isi::params::cinder_db_password,
  $cinder_db_dbname       = $isi::params::cinder_db_dbname,
  $quantum                = $isi::params::quantum,
  $quantum_db_user        = $isi::params::quantum_db_user,
  $quantum_db_password    = $isi::params::quantum_db_password,
  $quantum_db_dbname      = $isi::params::quantum_db_dbname,
  $allowed_hosts          = $isi::params::allowed_hosts,
  $enable                 = true
  ) {
  
  class { 'openstack::db::mysql':
    manage_mysql_server    => $manage_mysql_server,
    mysql_root_password    => $mysql_root_password,
    mysql_bind_address     => $mysql_bind_address,
    mysql_account_security => $mysql_account_security,
    keystone_db_user       => $keystone_db_user,
    keystone_db_password   => $keystone_db_password,
    keystone_db_dbname     => $keystone_db_dbname,
    glance_db_user         => $glance_db_user,
    glance_db_password     => $glance_db_password,
    glance_db_dbname       => $glance_db_dbname,
    nova_db_user           => $nova_db_user,
    nova_db_password       => $nova_db_password,
    nova_db_dbname         => $nova_db_dbname,
    cinder                 => $cinder,
    cinder_db_user         => $cinder_db_user,
    cinder_db_password     => $cinder_db_password,
    cinder_db_dbname       => $cinder_db_dbname,
    quantum                => $quantum,
    quantum_db_user        => $quantum_db_user,
    quantum_db_password    => $quantum_db_password,
    quantum_db_dbname      => $quantum_db_dbname,
    allowed_hosts          => $allowed_hosts,
    enabled                => $enabled,
  }
}
