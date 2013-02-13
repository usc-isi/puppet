
# # Class to create keystone endpoints

# ####### KEYSTONE ###########
# class { 'openstack::keystone':
#   verbose               => $verbose,
#   db_type               => $db_type,
#   db_host               => $db_host,
#   db_password           => $keystone_db_password,
#   db_name               => $keystone_db_dbname,
#   db_user               => $keystone_db_user,
#   admin_token           => $keystone_admin_token,
#   admin_tenant          => $keystone_admin_tenant,
#   admin_email           => $admin_email,
#   admin_password        => $keystone_admin_password,
#   public_address        => $keystone_host_public,
#   internal_address      => $keystone_host_private,
#   admin_address         => $keystone_host_public,
#   region                => $region,
#   glance_user_password  => $glance_db_password,
#   nova_user_password    => $nova_db_password,
#   cinder                => $cinder,
#   cinder_user_password  => $cinder_db_password,
#   quantum               => $quantum,
#   quantum_user_password => $quantum_db_password,
#   enabled               => $keystone,
# # Multi-node
#   glance_public_address    => $glance_host_public,
#   glance_internal_address  => $glance_host_internal,
#   glance_admin_address     => $glance_host_public,
#   nova_public_address      => $nova_host_public,
#   nova_internal_address    => $nova_host_internal,
#   nova_admin_address       => $nova_host_public,
#   cinder_public_address    => $cinder_host_public,
#   cinder_internal_address  => $cinder_host_internal,
#   cinder_admin_address     => $cinder_host_public,
#   quantum_public_address   => $quantum_host_public,
#   quantum_internal_address => $quantum_host_internal,
#   quantum_admin_address    => $quantum_host_public,
# }

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

class { 'quantum::plugins::agents-setup':
  quantum_password  => $quantum_admin_password,
  plugin            => 'linuxbridge',
  vlan              => $linux_bridge_physical_interface,
  user              => $quantum_admin_username,
  tenant            => $quantum_admin_tenant_name,
  auth_url          => $keystone_auth_url,
}
