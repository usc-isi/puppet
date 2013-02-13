# Resources for a network contoller node

node 'bespin106.east.isi.edu' {

  import 'defaults.pp'

  Exec {
    path => [
      '/usr/local/sbin',
      '/usr/sbin',
      '/sbin',
      '/bin',
      '/usr/local/bin',
      '/usr/bin'],

    logoutput => true,
  }

  import 'quantum-agent-config.pp'
  
  class { 'openstack::auth_file':
    admin_user           => $keystone_admin_user,
    admin_tenant         => $keystone_admin_tenant,
    controller_node      => $keystone_host_address,
    admin_password       => $keystone_admin_password,
    keystone_admin_token => $keystone_admin_token,
  }

}
