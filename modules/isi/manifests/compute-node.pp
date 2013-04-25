# == Class isi::compute-node
#
# Wrapper for openstack::compute class with some additional resources.
#
# === Parameters
#
# See isi::params for explanations of parameters pulled from that class.
#
# [internal_address    ] IP address of compute node. Usually, $::ipaddress is fine. Required.
# Deprecated Nova Networks settings
# [fixed_network_range ] Deprecated with Folsom. Default undef.
# [network_manager     ] Deprecated with Folsom. Default undef.
# [network_config      ]  Deprecated with Folsom. Default undef.
# [multi_host          ]  Deprecated with Folsom. Default undef.
# Deprecated Nova Networks settings END
# [glance_port         ] Glance service port. Optional. Default 9292.
# [quantum             ] Set to true to use Quantum. (deprecated nova-networks not supported.) Optional. Default true.
# [purge_nova_config   ] Only include options from Puppet in nova.conf. (Buggy) Optional. Default false.
# [libvirt_type        ] Type of virtualization. Optional. Default kvm.
# [vnc_enabled         ] Enable VNC support. Optional. Default true.
# [cinder              ] Enable Cinder services. (nova-volume is deprecated.) Optional. Default true.
# [manage_volumes      ] Optional. Default false.
# [nova_volume         ] Name of logical volume used for storage of VM disks. Optional. Default 'cinder-volumes'.
# [migration_support   ] Enable live migration of VM images. Optional. Default false.
# [enabled             ] Enable Nova services. Optional. Default true.
# [create_openrc       ] Create openrc file on this node using openstack::auth_file. Optional. Default false.
#
# === Examples
#
#  class {'isi::compute-node':
#    internal_address => "$::ipaddress",
#  }
#
# === Authors
#
# Craig E. Ward <cward@isi.edu>
#
class isi::compute-node (
  # Required
  $internal_address,      #  Usually, $::ipaddress is fine.
  # ISI defaults
  $glance_host_public                       = $isi::params::glance_host_public,
  $rabbit_password                          = $isi::params::rabbit_password,
  $nova_sql_connection                      = $isi::params::nova_sql_connection,
  $public_interface                         = $isi::params::public_interface,
  $private_interface                        = $isi::params::private_interface,
  $quantum_sql_connection                   = $isi::params::quantum_sql_connection,
  $quantum_server_host                      = $isi::params::quantum_server_host,
  $quantum_admin_tenant_name                = $isi::params::quantum_admin_tenant_name,
  $quantum_admin_username                   = $isi::params::quantum_admin_username,
  $quantum_admin_password                   = $isi::params::quantum_admin_password,
  $quantum_db_password                      = $isi::params::quantum_db_password,
  $quantum_agent_plugin                     = $isi::params::quantum_agent_plugin,
  $quantum_agents_host                      = $isi::params::quantum_host_address,
  $libvirt_vif_driver                       = $isi::params::libvirt_vif_driver,
  $keystone_auth_url                        = $isi::params::keystone_auth_url,
  $keystone_host_public                     = $isi::params::keystone_host_public,
  $rabbit_host                              = $isi::params::rabbit_host,
  $rabbit_user                              = $isi::params::rabbit_user,
  $rabbit_virtual_host                      = $isi::params::rabbit_virtual_host,
  $nova_host_internal                       = $isi::params::nova_host_internal,
  $vncserver_listen                         = $isi::params::vncserver_listen,
  $cinder_host_internal                     = $isi::params::cinder_host_internal,
  $cinder_volume_group                      = $isi::params::cinder_volume_group,
  $verbose                                  = $isi::params::verbose,
  $nova_admin_tenant                        = $isi::params::nova_admin_tenant,
  $nova_admin_user                          = $isi::params::nova_admin_user,
  $nova_user_password                       = $isi::params::nova_admin_password,
  $purge_nova_config                        = $isi::params::purage_nova_config,
  # Defaults for most installations
  $linux_bridge                             = $isi::params::linux_bridge,  
  $linux_bridge_tenant_network_type         = $isi::params::linux_bridge_tenant_network_type,
  $linux_bridge_network_vlan_ranges         = $isi::params::linux_bridge_network_vlan_ranges,
  $linux_bridge_physical_interface_mappings = $isi::params::linux_bridge_physical_interface_mappings,
# Deprecated Nova Networks settings
  $fixed_network_range                      = undef,  # Nova Network (Ignored for Quatum?)
  $network_manager                          = undef,  # ditto
  $network_config                           = {},     # nova-network only; not used by quantum
  $multi_host                               = false,  # nova-network only; ignored by quantum
# Deprecated Nova Networks settings END
  $glance_port                              = '9292',
  $quantum                                  = true,
  $purge_nova_config                        = false,
  $libvirt_type                             = 'kvm',
  $vnc_enabled                              = true,
  $cinder                                   = true,
  $manage_volumes                           = false,
  $nova_volume                              = 'cinder-volumes',
  $migration_support                        = false,
  $enabled                                  = true,
  $create_openrc                            = false
  ) {
    
  class { 'openstack::compute':
    internal_address                         => $internal_address,
    nova_admin_tenant_name                   => $nova_admin_tenant,
    nova_admin_user                          => $nova_admin_user,
    nova_admin_password                      => $nova_user_password,
    rabbit_password                          => $rabbit_password,
    sql_connection                           => $nova_sql_connection,
    public_interface                         => $public_interface,
    private_interface                        => $private_interface,
# Deprecated Nova Networks settings
    fixed_range                              => $fixed_network_range,
    network_manager                          => $network_manager,
    network_config                           => $network_config,
    multi_host                               => $multi_host,
# Deprecated NOVA settings End
    keystone_auth_url                        => $keystone_auth_url,
    quantum                                  => $quantum,
    quantum_db_password                      => $quantum_db_password,
    quantum_sql_connection                   => $quantum_sql_connection,
    quantum_host                             => $quantum_server_host,
    quantum_user_password                    => $quantum_db_password,
    quantum_admin_username                   => $quantum_admin_username,    
    quantum_admin_tenant_name                => $quantum_admin_tenant_name,
    quantum_admin_password                   => $quantum_admin_password,
    quantum_agent_plugin                     => $quantum_agent_plugin,
    libvirt_vif_driver                       => $libvirt_vif_driver,
    keystone_host                            => $keystone_host_public,
    purge_nova_config                        => $purge_nova_config,
    linux_bridge                             => $linux_bridge,
    linux_bridge_tenant_network_type         => $linux_bridge_tenant_network_type,
    linux_bridge_network_vlan_ranges         => $linux_bridge_network_vlan_ranges,
    linux_bridge_physical_interface_mappings => $linux_bridge_physical_interface_mappings,
    rabbit_host                              => $rabbit_host,
    rabbit_user                              => $rabbit_user,
    rabbit_virtual_host                      => $rabbit_virtual_host,
    glance_api_servers                       => "${glance_host_public}:${glance_port}",
    libvirt_type                             => $libvirt_type,
    vnc_enabled                              => $vnc_enabled,
    vncproxy_host                            => $nova_host_internal,
    vncserver_listen                         => $vncserver_listen,
    cinder                                   => $cinder,
    cinder_sql_connection                    => "mysql://${cinder_db_user}:${cinder_db_password}@${db_host}/${cinder_db_name}",
    manage_volumes                           => $manage_volumes,
    nova_volume                              => $cinder_volume_group,
    iscsi_ip_address                         => $cinder_host_internal,
    migration_support                        => $migration_support,
    verbose                                  => $verbose,
    enabled                                  => $enabled,
  }


 Class['openstack::compute'] -> Class['quantum::agents::l3_server_setup']

# Because the quantum::agents::l3 class  doesn't stick?
  class { 'quantum::agents::l3_server_setup':
      auth_password           => $quantum_admin_password,
      auth_user               => $quantum_admin_username,
      auth_tenant             => $quantum_admin_tenant_name,
      linux_plugin            => $quantum_agent_plugin,
      auth_url                => $keystone_auth_url,
    }

 if $create_openrc {
   class { 'isi::auth_file': }
   # class { 'openstack::auth_file':
   #   admin_user           => $keystone_admin_user,
   #   admin_tenant         => $keystone_admin_tenant,
   #   controller_node      => $keystone_host_address,
   #   admin_password       => $keystone_admin_password,
   #   keystone_admin_token => $keystone_admin_token,
   # }
 }
}
