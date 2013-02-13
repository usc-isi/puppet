# Resources for a keystone contoller node

node 'bespin104.east.isi.edu' {

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

  # $rabbit_password           = 'd0dcSdba'  # Old bespin103
  # $rabbit_user               = 'nova'      # Old bespin103
  
  # # Enable these endpoints
  # $glance   = true
  # $cinder   = true
  # $quantum  = true
  # $nova     = true
  # $keystone = true

  #  import 'keystone-config.pp'
  # Class to create keystone endpoints

  ####### KEYSTONE ###########
  class { 'openstack::keystone':
    verbose               => $verbose,
    db_type               => $db_type,
    db_host               => $db_host,
    db_password           => $keystone_db_password,
    db_name               => $keystone_db_dbname,
    db_user               => $keystone_db_user,
    admin_token           => $keystone_admin_token,
    admin_tenant          => $keystone_admin_tenant,
    admin_email           => $admin_email,
    admin_password        => $keystone_admin_password,
    public_address        => $keystone_host_public,
    internal_address      => $keystone_host_private,
    admin_address         => $keystone_host_public,
    region                => $region,
    glance_user_password  => $glance_db_password,
    nova_user_password    => $nova_db_password,
    cinder                => $cinder,
    cinder_user_password  => $cinder_db_password,
    quantum               => $quantum,
    quantum_user_password => $quantum_db_password,
    enabled               => $keystone,
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
    quantum_public_address   => $quantum_host_public,
    quantum_internal_address => $quantum_host_internal,
    quantum_admin_address    => $quantum_host_public,
  }


  #  import 'glance-config.pp'

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
    auth_uri                  => "http://${keystone_host}:5000/v2.0/",
  }

  Class['openstack::keystone'] -> Class['openstack::auth_file']

  class { 'openstack::auth_file':
    admin_user           => $keystone_admin_user,
    admin_tenant         => $keystone_admin_tenant,
    controller_node      => $keystone_host_address,
    admin_password       => $keystone_admin_password,
    keystone_admin_token => $keystone_admin_token,
  }


}
