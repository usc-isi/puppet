# == Class: isi::auth_file
#
# Wrapper for openstack::auth_file class. All of the values set from the
# isi::params class.
#
# === Parameters
#
# See isi::params for explanations of parameters.
#
# === Examples
#
#  class {'isi::auth_file': }
#
# === Authors
#
# Craig E. Ward <cward@isi.edu>
#
class isi::auth_file (
  $keystone_admin_user     = $isi::params::keystone_admin_user,
  $keystone_admin_tenant   = $isi::params::keystone_admin_tenant,
  $keystone_host_address   = $isi::params::keystone_host_address,
  $keystone_admin_password = $isi::params::keystone_admin_password,
  $keystone_admin_token    = $isi::params::keystone_admin_token
  ) {

  notify{ 'auth_file_message':
    message => "defining admin_user as $keystone_admin_user and keystone_admin_token as $keystone_admin_token.",
  }
  class { 'openstack::auth_file':
    admin_user           => $keystone_admin_user,
    admin_tenant         => $keystone_admin_tenant,
    controller_node      => $keystone_host_address,
    admin_password       => $keystone_admin_password,
    keystone_admin_token => $keystone_admin_token,
  }

}
