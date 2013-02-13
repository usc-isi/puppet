# Resources for a keystone contoller node

node 'bespin103.east.isi.edu' {

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


  # $public_interface   = 'eth0'
  # $private_interface  = 'eth1'
  # $glance_api_servers = "${glance_host_public}:9292"
  # $vnc_enabled        = true
  
  # $rabbit_password           = 'd0dcSdba'  # Old bespin103
  # $rabbit_user               = 'nova'      # Old bespin103
  
#  import 'nova-controller-config.pp'
# Configure the Nova controller services.

# Install / configure rabbitmq
class { 'nova::rabbitmq':
  userid        => $rabbit_user,
  password      => $rabbit_password,
  enabled       => $enabled,
  virtual_host  => $rabbit_virtual_host,
}

# Configure Nova
class { 'nova':
  sql_connection       => $nova_sql_connection,
  rabbit_userid        => $rabbit_user,
  rabbit_password      => $rabbit_password,
  rabbit_virtual_host  => $rabbit_virtual_host,
  image_service        => 'nova.image.glance.GlanceImageService',
  glance_api_servers   => "${glance_host_public}:9292",
  verbose              => $verbose,
  rabbit_host          => $rabbit_connection,
}

# Configure nova-api
class { 'nova::api':
  enabled           => $enabled,
  admin_password    => $nova_user_password,
  auth_host         => $keystone_host_public,
}


class { 'nova::compute::quantum':
  # DODCS Begin
  libvirt_vif_driver => 'nova.virt.libvirt.vif.QuantumLinuxBridgeVIFDriver',
  # DODCS End
}
# DODCS
nova_config {
  'linuxnet_interface_driver':       value => 'nova.network.linux_net.QuantumLinuxBridgeInterfaceDriver';
}

# Set up Quantum
$quantum_sql_connection = "mysql://${quantum_db_user}:${quantum_db_password}@${db_host}/${quantum_db_dbname}?charset=utf8"
class { 'quantum':
  verbose         => $verbose,
  debug           => $verbose,
  rabbit_host     => $rabbit_host, # DODCS
  rabbit_user     => $rabbit_user,
  rabbit_password => $rabbit_password,
  core_plugin     => 'quantum.plugins.linuxbridge.lb_quantum_plugin.LinuxBridgePluginV2', # DODCS
  rpc_backend      =>'quantum.openstack.common.rpc.impl_kombu',
  api_paste_config => '/etc/quantum/api-paste.ini',
}

class { 'quantum::server':
  auth_password => $quantum_admin_password,     # DODCS
  auth_user     => $quantum_admin_username,     # DODCS
  auth_tenant   => $quantum_admin_tenant_name,  # DODCS
}

class { 'quantum::agents::dhcp':
  # DODCS Begin
  quantum_username => $quantum_admin_username,
  quantum_password => $quantum_admin_password,
  quantum_admin_tenant => $quantum_admin_tenant_name,
  keystone_auth_url => $keystone_auth_url,
  interface_driver => 'quantum.agent.linux.interface.BridgeInterfaceDriver',
  use_namespaces   => 'False',
  debug            => $verbose,
  # DODCS End
}

## DODCS Begin
class { 'quantum::agents::l3':
  interface_driver        => 'quantum.agent.linux.interface.BridgeInterfaceDriver',
  use_namespaces          => 'False',
  external_network_bridge => undef,
  metadata_ip             => '127.0.0.1',
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

class { 'quantum::plugins::server':
  quantum_password  => $quantum_admin_password,
  mysql_root        => $mysql_root_password,
  plugin            => 'linuxbridge',
  vlan              => $linux_bridge_physical_interface,
  user              => $quantum_admin_username,
  tenant            => $quantum_admin_tenant_name,
  auth_url          => $keystone_auth_url,
}


#    Class['quantum::agents::l3_server_setup'] ~> Class['quantum::agents::l3']

# Because the quantum::agents::l3 class  doesn't stick?
class { 'quantum::agents::l3_server_setup':
  auth_password           => $quantum_admin_password,
  auth_user               => $quantum_admin_username,
  auth_tenant             => $quantum_admin_tenant_name,
  linux_plugin            => 'linuxbridge',
  auth_url                => $keystone_auth_url,
}

##DODCS End

class { 'nova::network::quantum':
  fixed_range               => $fixed_network_range,         # DODCS: Correct place? Even used in Folsom with Quantum?
  quantum_admin_password    => $quantum_admin_password,      # DODCS
  #$use_dhcp                  = 'True',
  #$public_interface          = undef,
  quantum_connection_host   => $quantum_server_host,
  quantum_auth_strategy     => 'keystone',
  quantum_url               => "http://${quantum_server_host}:9696/",
  quantum_admin_tenant_name => $quantum_admin_tenant_name,   # DODCS
  quantum_admin_username    => $quantum_admin_username,      # DODCS
  quantum_admin_auth_url    => "http://${keystone_host_public}:35357/v2.0/",
}

# a bunch of nova services that require no configuration
class { [
         'nova::scheduler',
         'nova::objectstore',
         'nova::cert',
         'nova::consoleauth'
         ]:
           enabled => $enabled,
}

if $vnc_enabled {
  class { 'nova::vncproxy':
    host    => $public_address,
    enabled => $enabled,
  }
}

# class { 'openstack::nova::controller':
#   # Database
#   db_host                 => $db_host,
#   # Network
#   network_manager         => $network_manager,
#   network_config          => $network_config,
#   floating_range          => $floating_range,
#   fixed_range             => $fixed_range,
#   public_address          => $nova_host_public,
#   admin_address           => $admin_address,
#   internal_address        => $internal_address_real,
#   auto_assign_floating_ip => $auto_assign_floating_ip,
#   create_networks         => $create_networks,
#   num_networks            => $num_networks,
#   multi_host              => $multi_host,
#   public_interface        => $public_interface,
#   private_interface       => $private_interface,
#   linux_bridge            => $linux_bridge,
#   # Quantum
#   quantum                 => $quantum,
#   quantum_user_password   => $quantum_user_password,
#   quantum_db_password     => $quantum_db_password,
#   quantum_db_user         => $quantum_db_user,
#   quantum_db_dbname       => $quantum_db_dbname,
#   # Nova
#   nova_user_password      => $nova_user_password,
#   nova_db_password        => $nova_db_password,
#   nova_db_user            => $nova_db_user,
#   nova_db_dbname          => $nova_db_dbname,
#   # Rabbit
#   rabbit_user             => $rabbit_user,
#   rabbit_password         => $rabbit_password,
#   rabbit_virtual_host     => $rabbit_virtual_host,
#   # Glance
#   glance_api_servers      => $glance_api_servers,
#   # VNC
#   vnc_enabled            => $vnc_enabled,
#   # General
#   verbose                 => $verbose,
#   enabled                 => $enabled,
# }

  
#  Class['openstack::nova::controller'] -> Class['openstack::auth_file']

  class { 'openstack::auth_file':
    admin_user           => $keystone_admin_user,
    admin_tenant         => $keystone_admin_tenant,
    controller_node      => $keystone_host_address,
    admin_password       => $keystone_admin_password,
    keystone_admin_token => $keystone_admin_token,
  }


}
