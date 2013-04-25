#
# == Class: isi::params
#
# Class sets global default values for all node types in the isi module. This
# class must be declared before the other resource classes. The classes in the
# isi module use these values for their default values.
#
# See body for additional parameters set using values from the argument list.
#
# === Parameters
# 
# [rabbit_host               ] IP address of host running rabbitmqserver. Required.
# [keystone_host_address     ] IP of host running Keystone authentication service. Required.
# [quantum_host_address      ] IP of host running Quantum agent services. Required.
# [cinder_host_address       ] IP of host running Cinder scheduler. Required.
# [glance_host_address       ] IP of host running Glance image server. Required.
# [cinder_iscsi_ip_addr      ] Node just running cinder-volume report this IP to scheduler.  Required.
# [nova_host_address         ] IP of host running Nova API, scheduler, and other support services. Required.
# [quantum_server_host       ] IP of host running the Quantum server; usually same as nova_host_address. Required.
# [db_host                   ] IP of host running the database server; usually MySQL. Required.
# [public_interface          ] Interface device for inter-service communications. Required.
# [private_interface         ] Interface device that will be used for the vm network. Required.
# [vncserver_listen          ] IP address compute nodes listen on for VNC. Optional. Defaults to $::ipaddress.
# [dnsmasq_dns_server        ] IP address of dnsmasq service. Optional. Defaults to undef. <?>
# [db_type                   ] Type of database server. Many require MySQL. Optional. Defaults to 'mysql'.
# [mysql_root_password       ] Password for the MySQL root account. Optional. Defaults to 'sql_pass'.
# [mysql_bind_address        ] Interfaces to listen for connection requests. Optional. Defaults to '0.0.0.0' (Listen on all networks).
# [mysql_account_security    ] Enable security cleanups on default MySQL installations. Optional. Defaults to true (Remove test db and guest accounts).
# [allowed_hosts             ] List of hosts allowed to try connections. Optional. Defaults to '%' (Allow any host to try connecting).
# [manage_mysql_server       ] Tell Puppet to manage this service. Optional. Defaults to true. (False causes problems in HA MySQL.)
# [verbose                   ] Enable or disable verbose logging for OpenStack services. Optional. Defaults to 'true'.
# [swift                     ] Use swift service. Optional. Defaults to false.
# [libvirt_type              ] Type of virtualization. Optional. Defaults to 'kvm'.
# [horizon                   ] Include Horizon Dashboard. Optional. Defaults to true.
# [horizon_secrete_key       ] Optional. Defaults to 'horizon_secrete_key'.
# [admin_email               ] Optional. Defaults to 'root@localhost'.
# [rabbit_password           ] Optional. Defaults to 'dbsecrete'.
# [rabbit_user               ] Optional. Defaults to 'nova'.
# [rabbit_virtual_host       ] Optional. Defaults to '/'.
# [rabbit_enabled            ] Optional. Defaults to true.
# [keystone_admin_token      ] Security token for Keystone CLI. Optional. Defaults to '999888777666'.
# [keystone_admin_user       ] Optional. Defaults to 'admin'.
# [keystone_admin_tenant     ] Optional. Defaults to 'admin'.
# [keystone_admin_password   ] Optional. Defaults to 'secrete'.
# [keystone_db_user          ] User for database connections. Optional. Defaults to 'keystone'.
# [keystone_db_password      ] Password for keystone database. Optional. Defaults to 'keystone_dba'.
# [keystone_db_dbname        ] Name to use for keystone database. Optional. Defaults to 'keystone'.
# [glance_db_user            ] User for database connections. Optional. Defaults to 'glance'.
# [glance_db_password        ] Password for database connections. Optional. Defaults to 'glance_dba'.
# [glance_db_dbname          ] Name to use for database. Optional. Defaults to 'glance'.
# [glance_user_password      ] User to use for Keystone authorization queries. Optional. Defaults to 'glance_keystone'.
# [nova_db_user              ] User for database connections. Optional. Defaults to 'nova'.
# [nova_db_password          ] Password for database connections. Optional. Defaults to 'nova_dba'.
# [nova_db_dbname            ] Name to use for database. Optional. Defaults to 'nova'.
# [nova_rpc_backend          ] RPC driver. Optional. Defaults to 'nova.rpc.impl_kombu'.
# [nova_admin_password       ] Password to use for Keystone queries. Optional. Defaults to 'secrete'.
# [nova_admin_tenant         ] Tenant for use with Keystone queries. Optional. Defaults to 'services'. (Used for all services.)
# [nova_admin_user           ] User to use for Keystone authorization queries. Optional. Defaults to 'nova'.
# [fixed_network_range       ] Deprecated nova-networks value. Optional. Defaults to undef. (Deprecated. Only used by nova-networks.)
# [purge_nova_config         ] Only include settings in nova.conf generated by Puppet. Optional. Defaults to false.
# [cinder                    ] Enable cinder services (not nova-volume). Optional. Defaults to true.
# [cinder_db_user            ] User for database connections. Optional. Defaults to 'cinder'.
# [cinder_db_password        ] Password for database connections. Optional. Defaults to 'cinder_dba'.
# [cinder_db_dbname          ] Name to use for database. Optional. Defaults to 'cinder'.
# [cinder_volumes_dir        ] Directory for cinder management data. Optional. Defaults to '/etc/cinder/volumes'.
# [cinder_volume_group       ] Logical volume for allocating virtual volumes. Optional. Defaults to 'cinder-volumes'.
# [cinder_admin_user         ] User to use for Keystone authorization queries. Optional. Defaults to 'cinder'.
# [cinder_admin_tenant       ] Tenant for use with Keystone queries. Optional. Defaults to 'services'.
# [cinder_admin_password     ] Password to use for Keystone queries. Optional. Defaults to 'cinder_keystone'.
# [cinder_rpc_backend        ] RPC driver. Optional. Defaults to 'cinder.openstack.common.rpc.impl_kbu'.
# [quantum                   ] Enable Quantum services (not nova-networks). Optional. Defaults to true. (nova-networks not supported.)
# [quantum_admin_password    ] Password to use for Keystone queries. Optional. Defaults to 'servicepass'.
# [quantum_admin_tenant_name ] Tenant for use with Keystone queries. Optional. Defaults to 'services'.
# [quantum_admin_username    ] User to use for Keystone authorization queries. Optional. Defaults to 'quantum'.
# [quantum_db_user           ] User for database connections. Optional. Defaults to 'quantum'.
# [quantum_db_password       ] Password for database connections. Optional. Defaults to 'quantum_dba'.
# [quantum_db_dbname         ] Name to use for database. Optional. Defaults to 'quantum_linux_bridge'.
# [quantum_rpc_backend       ] RPC driver. Optional. Defaults to 'quantum.openstack.common.rpc.impl_mbu'.
# [quantum_agent_plugin      ] Quantum networking plug-in for compute nodes. Optional. Defaults to 'linuxbridge'.
# [libvirt_vif_driver        ] Driver for virtualizations. Optional. Defaults to 'nova.virt.libvirt.vif.QuantumLinuxidgeVIFDriver'.
# [region                    ] Nova region label. Optional. Defaults to 'RegionOne'.
# [linux_bridge              ] Enable Quantum linuxbridge plug-in. Optional. Defaults to true.
# [linux_bridge_tenant_network_type] Optional. Defaults to 'vlan'.
# [linux_bridge_network_vlan_ranges] Optional. Defaults to "physnet1:1000:2999".
# [linux_bridge_physical_interface_mappings] Optional. Defaults to 'physnet1:eth1.
#
# === Examples
#
# class { 'isi::params':
#   rabbit_host           => '10.0.5.5',
#   quantum_server_host   => '10.0.5.5',
#   db_host               => '127.0.0.1',
#   keystone_host_address => '10.0.5.5',
#   cinder_host_address   => '10.0.5.5',
#   nova_host_address     => '10.0.5.5',
#   quantum_host_address  => '10.0.5.5',
#   cinder_iscsi_ip_addr  => '10.0.5.5',
#   glance_host_address   => '10.0.5.5',
#   public_interface      => 'eth0',
#   private_interface     => 'eth1',
#   vncserver_listen      => $::ipaddress_eth0,
#   }
#
# === Authors
#
# Craig E. Ward <cward@isi.edu>
#
#
class isi::params (
  # Required
  $rabbit_host,
  $keystone_host_address,
  $quantum_host_address,
  $cinder_host_address,
  $glance_host_address,
  # Node just running cinder-volume
  $cinder_iscsi_ip_addr,
  $nova_host_address,
  $quantum_server_host, # usually same as nova_host_address
  $db_host,
  # interface for inter-service communications
  $public_interface,
  # assumes that eth1 is the interface that will be used for the vm network
  # this configuration assumes this interface is active but does not have an
  # ip address allocated to it.
  $private_interface,
  # For compute nodes
  $vncserver_listen                         = $::ipaddress,
  $dnsmasq_dns_server                       = undef,
  # MySQL
  $db_type                                  = 'mysql',
  $mysql_root_password                      = 'sql_pass',
  $mysql_bind_address                       = '0.0.0.0', # listen on network
  $mysql_account_security                   = true,      # remove test db and guest account
  $allowed_hosts                            = '%',       # Allow any host to try
  $manage_mysql_server                      = true,

  # switch this to true to have all service log at verbose
  $verbose                                  = 'true',
  $swift                                    = false,
  $libvirt_type                             = 'kvm',
  # credentials
  $horizon                                  = true,
  $horizon_secrete_key                      = 'horizon_secrete_key',
  $admin_email                              = 'root@localhost',
  $rabbit_password                          = 'dbsecrete',
  $rabbit_user                              = 'nova',
  $rabbit_virtual_host                      = '/',
  $rabbit_enabled                           = true,
  $keystone_admin_token                     = '999888777666',
  $keystone_admin_user                      = 'admin',
  $keystone_admin_tenant                    = 'admin',
  $keystone_admin_password                  = 'secrete',
  $keystone_db_user                         = 'keystone',
  $keystone_db_password                     = 'keystone_dba',
  $keystone_db_dbname                       = 'keystone',
  $glance_db_user                           = 'glance',
  $glance_db_password                       = 'glance_dba',
  $glance_db_dbname                         = 'glance',
  $glance_user_password                     = 'glance_keystone',
  $nova_db_user                             = 'nova',
  $nova_db_password                         = 'nova_dba',
  $nova_db_dbname                           = 'nova',
  $nova_rpc_backend                         = 'nova.rpc.impl_kombu',
  $nova_admin_password                      = 'secrete',
  $nova_admin_tenant                        = 'services', # Used for all services
  $nova_admin_user                          = 'nova',
  $fixed_network_range                      = undef, # nova-networks uses this
  $purge_nova_config                        = false,
  $cinder                                   = true,
  $cinder_db_user                           = 'cinder',
  $cinder_db_password                       = 'cinder_dba',
  $cinder_db_dbname                         = 'cinder',
  $cinder_volumes_dir                       = '/etc/cinder/volumes',
  $cinder_volume_group                      = 'cinder-volumes',
  $cinder_admin_user                        = 'cinder',
  $cinder_admin_tenant                      = 'services',
  $cinder_admin_password                    = 'cinder_keystone',
  $cinder_rpc_backend                       = 'cinder.openstack.common.rpc.impl_kombu',
  $quantum                                  = true,
  $quantum_admin_password                   = 'servicepass',
  $quantum_admin_tenant_name                = 'services',
  $quantum_admin_username                   = 'quantum',
  $quantum_db_user                          = 'quantum',
  $quantum_db_password                      = 'quantum_dba',
  $quantum_db_dbname                        = 'quantum_linux_bridge',
  $quantum_rpc_backend                      = 'quantum.openstack.common.rpc.impl_kombu',
  $quantum_agent_plugin                     = 'linuxbridge',
  $libvirt_vif_driver                       = 'nova.virt.libvirt.vif.QuantumLinuxBridgeVIFDriver',
  $region                                   = 'RegionOne',
  $linux_bridge                             = true,
  $linux_bridge_tenant_network_type         = 'vlan',
  $linux_bridge_network_vlan_ranges         = "physnet1:1000:2999",
  $linux_bridge_physical_interface_mappings = 'physnet1:eth1'
  ) {

  #####
  # The other classes used for configuring OpenStack include these names.
  # However, they are (nearly) always assigned other values by default. It
  # isn't clear if these should be separate values or not.
  ####
  
  # multi-node specific parameters
  $rabbit_connection                        = $rabbit_host
  $keystone_host_public                     = $keystone_host_address
  $keystone_host_internal                   = $keystone_host_address
  $glance_host_public                       = $glance_host_address
  $glance_host_internal                     = $glance_host_address
  $quantum_host_public                      = $quantum_host_address
  $quantum_host_internal                    = $quantum_host_address
  # Cinder host for "controller" node
  $cinder_host_public                       = $cinder_host_address
  $cinder_host_internal                     = $cinder_host_address
  $nova_host_public                         = $nova_host_address
  $nova_host_internal                       = $nova_host_address

  $nova_sql_connection    = "mysql://${nova_db_user}:${nova_db_password}@${db_host}/nova"
  $keystone_auth_url      = "http://${keystone_host_public}:5000/v2.0/"
  $quantum_sql_connection = "mysql://${quantum_db_user}:${quantum_db_password}@${db_host}/${quantum_db_dbname}?charset=utf8"

  # notify {'nova_sql':
  #   message => "$nova_sql_connection",
  # }
  # notify {'keystone_sql':
  #   message => "$keystone_sql_connection",
  # }
  # notify {'quantum_sql':
  #   message => "$quantum_sql_connection",
  # }
    
  }
