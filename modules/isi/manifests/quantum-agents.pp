# == Class: isi::quantum-agents
# 
# Define a node to run the Quantum agent services.
#
# === Parameters
#
# See isi::params for explanations of parameters pulled from that class.
#
# [quantum_core_plugin      ] Plug-in class. Optional. Default quantum.plugins.linuxbridge.lb_quantum_plugin.LinuxBridgePluginV2.
# [quantum_api_paste_config ] API initialization file Optional. Default /etc/quantum/api-paste.ini.
# [quantum_interface_driver ] Quantum driver class. Optional. Default  quantum.agent.linux.interface.BridgeInterfaceDriver.
# [quantum_use_namespaces   ] Flag to use namespaces with Quantum. Goes into ini file as string. Optional. Default 'False.'
#
# === Examples
#
#  class {'isi::quantum-agents':
#    verbose => false,
#  }
#
# === Authors
#
# Craig E. Ward <cward@isi.edu>
#
class isi::quantum-agents (
  $keystone_auth_url                        = $isi::params::keystone_auth_url,
  $linux_bridge_network_vlan_ranges         = $isi::params::linux_bridge_network_vlan_ranges,
  $linux_bridge_physical_interface          = $isi::params::linux_bridge_physical_interface,
  $linux_bridge_physical_interface_mappings = $isi::params::linux_bridge_physical_interface_mappings,
  $linux_bridge_tenant_network_type         = $isi::params::linux_bridge_tenant_network_type,
  $nova_host_internal                       = $isi::params::nova_host_internal,
  $quantum_db_dbname                        = $isi::params::quantum_db_dbname,
  $quantum_db_user                          = $isi::params::quantum_db_user,
  $quantum_db_password                      = $isi::params::quantum_db_password,
  $quantum_admin_password                   = $isi::params::quantum_admin_password,
  $quantum_admin_tenant_name                = $isi::params::quantum_admin_tenant_name,
  $quantum_admin_username                   = $isi::params::quantum_admin_username,
  $quantum_sql_connection                   = $isi::params::quantum_sql_connection,
  $quantum_rpc_backend                      = $isi::params::quantum_rpc_backend,
  $rabbit_host                              = $isi::params::rabbit_host,
  $rabbit_password                          = $isi::params::rabbit_password,
  $rabbit_user                              = $isi::params::rabbit_user,
  $verbose                                  = $isi::params::verbose,
  $quantum_agent_plugin                     = $isi::params::quantum_agent_plugin,
  $quantum_core_plugin                      = 'quantum.plugins.linuxbridge.lb_quantum_plugin.LinuxBridgePluginV2',
  $quantum_api_paste_config                 = '/etc/quantum/api-paste.ini',
  $quantum_interface_driver                 = 'quantum.agent.linux.interface.BridgeInterfaceDriver',
  $quantum_use_namespaces                   = 'False' # Goes into ini file as string.
  ) {
  
  class { 'quantum':
    verbose          => $verbose,
    debug            => $verbose,
    rabbit_host      => $rabbit_host,
    rabbit_user      => $rabbit_user,
    rabbit_password  => $rabbit_password,
    core_plugin      => $quantum_core_plugin,
    rpc_backend      => $quantum_rpc_backend,
    api_paste_config => $quantum_api_paste_config,
  }

  class { 'quantum::agents::dhcp':
    # DODCS Begin
    quantum_username     => $quantum_admin_username,
    quantum_password     => $quantum_admin_password,
    quantum_admin_tenant => $quantum_admin_tenant_name,
    keystone_auth_url    => $keystone_auth_url,
    interface_driver     => $quantum_interface_driver,
    use_namespaces       => $quantum_use_namespaces,
    debug                => $verbose,
    # DODCS End
  }

  ## DODCS Begin
  class { 'quantum::agents::l3':
    interface_driver        => $quantum_interface_driver,
    use_namespaces          => $quantum_use_namespaces,
    external_network_bridge => undef,
    metadata_ip             => $nova_host_internal,
    auth_password           => $quantum_admin_password,
    auth_user               => $quantum_admin_username,
    auth_tenant             => $quantum_admin_tenant_name,
    debug                   => $verbose,
  }

  class { 'quantum::plugins::linuxbridge':
    sql_connection              => $quantum_sql_connection,
    tenant_network_type         => $linux_bridge_tenant_network_type,
    network_vlan_ranges         => $linux_bridge_network_vlan_ranges,
    physical_interface          => $linux_bridge_physical_interface,
    physical_interface_mappings => $linux_bridge_physical_interface_mappings,
  }

  class { 'quantum::agents::linuxbridge': }

  class { 'quantum::plugins::agents-setup':
    quantum_server_host => $nova_host_internal,
    quantum_db_password => $quantum_db_password,
    quantum_password    => $quantum_admin_password,
    plugin              => $quantum_agent_plugin,
    vlan                => $linux_bridge_physical_interface,
    user                => $quantum_admin_username,
    tenant              => $quantum_admin_tenant_name,
    auth_url            => $keystone_auth_url,
  }

# Because the quantum::agents::l3 class  doesn't stick?
  class { 'quantum::agents::l3_server_setup':
    auth_password           => $quantum_admin_password,
    auth_user               => $quantum_admin_username,
    auth_tenant             => $quantum_admin_tenant_name,
    linux_plugin            => $quantum_agent_plugin,
    auth_url                => $keystone_auth_url,
    subscribe               => Class['quantum::agents::l3'],
  }
}
