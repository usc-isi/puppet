# == Class: isi::nova-controller
#
# Install services for a Nova Controller node. These are:
#  - nova services
#  - quantum server
#
# Flags to also include the quantum agents and compute nodes are set to
# false by default. You can have a single-node installation by setting both
# to true.
#
# === Parameters
#
# See isi::params for explanations of parameters pulled from that class.
#
# [glance_image_service      ] Driver for Glance image service. Optional. Default nova.image.glance.GlanceImageService.
# [glance_api_port           ] Service port for Glance. Optional. Default 9292.
# [libvirt_vif_driver        ] Virtualization interface driver. Optional. Default nova.virt.libvirt.vif.QuantumLinuxBridgeVIFDriver.
# [linuxnet_interface_driver ] Virtualization interface network driver. Optional. Default nova.network.linux_net.QuantumLinuxBridgeInterfaceDriver.
# [quantum_core_plugin       ] Quantum plug-in. Optional. Default quantum.plugins.linuxbridge.lb_quantum_plugin.LinuxBridgePluginV2.
# [quantum_api_paste_config  ] API initialization file. Optional. Default /etc/quantum/api-paste.ini.
# [quantum_interface_driver  ] Quantum network driver. Optional. Default quantum.agent.linux.interface.BridgeInterfaceDriver.
# [quantum_use_namespaces    ] Namespaces flag. (Goes into ini file as string.) Optional. Default "False".
# [quantum_agent_plugin      ] Name for Quantum agent plug-in. Optional. Default linuxbridge.
# [cache_server_ip           ] Optional. Default 127.0.0.1.
# [cache_server_port         ] Optional. Default 11211.
# [quantum_agents_enabled    ] Set true to get quantum agents installed. Optional. Default false.
# [nova_compute              ] Set true to have a compute node installed. Optional. Default false.
# [enabled                   ] Somewhat redundant; flag controls turning on the Nova services. Optional. Default true.
#
# === Examples
#
#  class {'isi::nova-controller':
#    quantum_agents_enabled => true, # Run quantum agents, too.
#    nova_compute           => true, # Run a compute node, too.
#  }
#
# === Authors
#
# Craig E. Ward <cward@isi.edu>
#
class isi::nova-controller (
  $keystone_host_public                     = $isi::params::keystone_host_public,
  $glance_host_public                       = $isi::params::glance_host_public,
  $linux_bridge_network_vlan_ranges         = $isi::params::linux_bridge_network_vlan_ranges,
  $linux_bridge_physical_interface          = $isi::params::private_interface,
  $linux_bridge_physical_interface_mappings = $isi::params::linux_bridge_physical_interface_mappings,
  $linux_bridge_tenant_network_type         = $isi::params::linux_bridge_tenant_network_type,
  $mysql_root_password                      = $isi::params::mysql_root_password,
  $nova_admin_tenant                        = $isi::params::nova_admin_tenant,
  $nova_admin_user                          = $isi::params::nova_admin_user,
  $nova_host_internal                       = $isi::params::nova_host_internal,
  $nova_sql_connection                      = $isi::params::nova_sql_connection,
  $nova_admin_password                      = $isi::params::nova_admin_password,
  $quantum_admin_password                   = $isi::params::quantum_admin_password,
  $quantum_admin_tenant_name                = $isi::params::quantum_admin_tenant_name,
  $quantum_admin_username                   = $isi::params::quantum_admin_username,
  $quantum_server_host                      = $isi::params::quantum_server_host,
  $quantum_sql_connection                   = $isi::params::quantum_sql_connection,
  $quantum_db_password                      = $isi::params::quantum_db_password,
  $quantum_rpc_backend                      = $isi::params::quantum_rpc_backend,
  $rabbit_connection                        = $isi::params::rabbit_connection,
  $rabbit_password                          = $isi::params::rabbit_password,
  $rabbit_user                              = $isi::params::rabbit_user,
  $rabbit_virtual_host                      = $isi::params::rabbit_virtual_host,
  $rabbit_enabled                           = $isi::params::rabbit_enabled,
  $verbose                                  = $isi::params::verbose,
  $libvirt_type                             = $isi::params::libvirt_type,
  $vnc_public_address                       = $isi::params::vnc_public_address,
  $vncserver_listen                         = $isi::params::vncserver_listen,
  $swift                                    = $isi::params::swift,
  $quantum                                  = $isi::params::quantum,
  $horizon                                  = $isi::params::horizon,
  $secret_key                               = $isi::params::horizon_secrete_key,
  $nova_rpc_backend                         = $isi::params::nova_rpc_backend,
  $purge_nova_config                        = $isi::params::purge_nova_config,
  $dnsmasq_dns_server                       = $isi::params::dnsmasq_dns_server,
  $glance_image_service                     = 'nova.image.glance.GlanceImageService',
  $glance_api_port                          = "9292",
  $libvirt_vif_driver                       = 'nova.virt.libvirt.vif.QuantumLinuxBridgeVIFDriver',
  $linuxnet_interface_driver                = 'nova.network.linux_net.QuantumLinuxBridgeInterfaceDriver',
  $quantum_core_plugin                      = 'quantum.plugins.linuxbridge.lb_quantum_plugin.LinuxBridgePluginV2',
  $quantum_api_paste_config                 = '/etc/quantum/api-paste.ini',
  $quantum_interface_driver                 = 'quantum.agent.linux.interface.BridgeInterfaceDriver',
  $quantum_use_namespaces                   = 'False', # Goes into ini file as string.
  $quantum_agent_plugin                     = 'linuxbridge',
  $cache_server_ip                          = '127.0.0.1',
  $cache_server_port                        = '11211',
  $quantum_agents_enabled                   = false,  # Set true to get quantum agents installed.
  $nova_compute                             = false,  # Set true to get a compute node installed.
  $enabled                                  = true
  ) {

  $keystone_auth_url = $isi::params::keystone_auth_url

  ######## BEGIN NOVA ###########
  #
  # indicates that all nova config entries that we did
  # not specifify in Puppet should be purged from file
  #
  if ($purge_nova_config) {
    resources { 'nova_config':
      purge => true,
    }
  }

  # Install / configure rabbitmq
  class { 'nova::rabbitmq':
    userid        => $rabbit_user,
    password      => $rabbit_password,
    enabled       => $rabbit_enabled,
    virtual_host  => $rabbit_virtual_host,
  }

  # Configure Nova
  class { 'nova':
    sql_connection         => $nova_sql_connection,
    rabbit_userid          => $rabbit_user,
    rabbit_password        => $rabbit_password,
    rabbit_virtual_host    => $rabbit_virtual_host,
    image_service          => $glance_image_service,
    glance_api_servers     => "${glance_host_public}:${glance_api_port}",
    verbose                => $verbose,
    rabbit_host            => $rabbit_connection,
    nova_admin_tenant_name => $nova_admin_tenant,
    nova_admin_user        => $nova_admin_user,
    nova_admin_password    => $nova_admin_password,
    rpc_backend            => $nova_rpc_backend,
  }


  # Configure nova-api
  class { 'nova::api':
    enabled           => $enabled,
    admin_password    => $nova_admin_password,
    auth_host         => $keystone_host_public,
  }

  class { 'nova::vncproxy':
    enabled => true,
    host    => $nova_host_internal,
  }

  # Set up Quantum
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

  class { 'quantum::server':
    auth_password => $quantum_admin_password,     # DODCS
    auth_user     => $quantum_admin_username,     # DODCS
    auth_tenant   => $quantum_admin_tenant_name,  # DODCS
  }

  class { 'quantum::plugins::linuxbridge':
    sql_connection              => $quantum_sql_connection,
    tenant_network_type         => $linux_bridge_tenant_network_type,
    network_vlan_ranges         => $linux_bridge_network_vlan_ranges,
    physical_interface          => $linux_bridge_physical_interface,
    physical_interface_mappings => $linux_bridge_physical_interface_mappings,
  }

  class { 'quantum::agents::linuxbridge':
    enabled => $quantum_agents_enabled,
  }

  # If this node needs to run quantum agents, include them.
  if $quantum_agents_enabled {

    class { 'quantum::agents::dhcp':
      # DODCS Begin
      quantum_username     => $quantum_admin_username,
      quantum_password     => $quantum_admin_password,
      quantum_admin_tenant => $quantum_admin_tenant_name,
      keystone_auth_url    => $keystone_auth_url,
      interface_driver     => $quantum_interface_driver,
      use_namespaces       => $quantum_use_namespaces,
      debug                => $verbose,
      enabled              => $quantum_agents_enabled,
      dnsmasq_dns_server   => $dnsmasq_dns_server,
      # DODCS End
    }

    class { 'quantum::agents::l3':
      interface_driver        => $quantum_interface_driver,
      use_namespaces          => $quantum_use_namespaces,
      external_network_bridge => undef,
      metadata_ip             => $nova_host_internal,
      auth_password           => $quantum_admin_password,
      auth_user               => $quantum_admin_username,
      auth_tenant             => $quantum_admin_tenant_name,
      enabled                 => $quantum_agents_enabled,
      debug                   => $verbose,
    }

    class { 'quantum::plugins::agents-setup':
      quantum_server_host => $quantum_server_host,
      quantum_db_password => $quantum_db_password,
      quantum_password    => $quantum_admin_password,
      plugin              => $quantum_agent_plugin,
      vlan                => $linux_bridge_physical_interface,
      user                => $quantum_admin_username,
      tenant              => $quantum_admin_tenant_name,
      auth_url            => $keystone_auth_url,
    }

    class { 'quantum::plugins::server':
      quantum_admin_password => $quantum_admin_password,
      quantum_db_password    => $quantum_db_password,
      mysql_root_pw          => $mysql_root_password,
      plugin                 => $quantum_agent_plugin,
      vlan                   => $linux_bridge_physical_interface,
      user                   => $quantum_admin_username,
      tenant                 => $quantum_admin_tenant_name,
      auth_url               => $keystone_auth_url,
      db_host                => $isi::params::db_host,
      keystone_host_internal => $isi::params::keystone_host_internal,
      subscribe              => Class['quantum::server'],
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
  } # end if quantum_agents_enabled


  class { 'nova::network::quantum':
    fixed_range               => $fixed_network_range,         # DODCS: undef by default; is it still needed?
    quantum_admin_password    => $quantum_admin_password,      # DODCS
    quantum_connection_host   => $quantum_server_host,
    quantum_auth_strategy     => 'keystone',
    quantum_url               => "http://${quantum_server_host}:9696",
    quantum_admin_tenant_name => $quantum_admin_tenant_name,   # DODCS
    quantum_admin_username    => $quantum_admin_username,      # DODCS
    quantum_admin_auth_url    => "http://${keystone_host_public}:35357/v2.0",
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
      host    => $vnc_public_address,
      enabled => $enabled,
    }
  }

  if $nova_compute {
    # Install / configure nova-compute
    class { '::nova::compute':
      enabled                       => $enabled,
      vnc_enabled                   => $vnc_enabled,
      vncserver_proxyclient_address => $nova_host_internal,
      vncproxy_host                 => $vnc_public_address,
    }

    # Configure libvirt for nova-compute
    class { 'nova::compute::libvirt':
      libvirt_type     => $libvirt_type,
      vncserver_listen => $vncserver_listen,
    }

    class { 'nova::compute::quantum':
      # DODCS Begin
      libvirt_vif_driver        => $libvirt_vif_driver,
      linuxnet_interface_driver => $linuxnet_interface_driver,
      # DODCS End
    }

  } # end if $nova_compute

  ######## Horizon ########
  if ($horizon) {
    class { 'openstack::horizon':
      secret_key        => $secret_key,
      keystone_host     => $keystone_host_public,
      cache_server_ip   => $cache_server_ip,
      cache_server_port => $cache_server_port,
      swift             => $swift,
      quantum           => $quantum,
    }
  }
  }
