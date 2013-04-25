# == Class: isi::glance
#
# Wrapper class for openstack::glance. All of the values set from the
# isi::params class.
#
# === Parameters
#
# See isi::params for explanations of parameters.
#
# === Examples
#
#  class {'isi::glance': }
#
# === Authors
#
# Craig E. Ward <cward@isi.edu>
#
class isi::glance (
  $verbose              = $isi::params::verbose,
  $db_type              = $isi::params::db_type,
  $db_host              = $isi::params::db_host,
  $glance_db_user       = $isi::params::glance_db_user,
  $glance_db_dbname     = $isi::params::glance_db_dbname,
  $glance_db_password   = $isi::params::glance_db_password,
  $glance_user_password = $isi::params::glance_user_password,
  $keystone_host_public = $isi::params::keystone_host_public,
  $keystone_auth_url    = $isi::params::keystone_auth_url,
  $enabled              = true
  ) {
  
  # Configuration for a glance service

  ######## BEGIN GLANCE ##########
  class { 'openstack::glance':
    verbose                   => $verbose,
    db_type                   => $db_type,
    db_host                   => $db_host,
    glance_db_user            => $glance_db_user,
    glance_db_dbname          => $glance_db_dbname,
    glance_db_password        => $glance_db_password,
    glance_user_password      => $glance_user_password,
    enabled                   => $enabled,
    keystone_host             => $keystone_host_public,
    auth_uri                  => $keystone_auth_url,
  }

}
