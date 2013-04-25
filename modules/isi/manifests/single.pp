# == Class: isi::single
#
# This class is sets up a single node installation of OpenStack Folsom. (It
# does not include any DODCS enhancements.) It has been superceeded by
# isi::nova-controller combined with isi::params.
#
# === Parameters
#
# See isi::params for explanations of parameters.
#
# === Examples
#
#  class { 'isi::single':
#    public_interface        => 'eth0',
#    private_interface       => 'eth1',
#    mysql_root_password     => 'sql_pass',
#    mysql_bind_address      => '127.0.0.1',
#    rabbit_password         => 'dbsecrete',
#    keystone_db_password    => 'keystone_dba',
#    glance_db_password      => 'glance_dba',
#    nova_db_password        => 'nova_dba',
#    nova_user_password      => 'secrete',
#    cinder_db_password      => 'cinder_dba',
#    keystone_admin_password => 'keystone_dba',
#    quantum_db_password     => 'servicepass',
#    quantum_admin_password  => 'servicepass',
#    keystone_admin_token    => '999888777666',
#    secret_key              => 'horizon_secrete_key',
#    horizon                 => false,
#  }
#
# === Authors
#
# Craig E. Ward <cward@isi.edu>
#
class isi::single(
  # Required network interfaces
  $public_interface,
  $private_interface,
  # Required passwords & keys
  $mysql_root_password,
  $rabbit_password,
  $keystone_db_password,
  $glance_db_password,
  $nova_db_password,
  $nova_user_password,
  $cinder_db_password,
  $keystone_admin_password,
  $quantum_db_password,
  $quantum_admin_password,
  $keystone_admin_token,
  $secret_key,
  # Addresses
  $keystone_host_address                    = $::ipaddress,
  $nova_host_address                        = $::ipaddress,
  $glance_host_address                      = $::ipaddress,
  $cinder_host_address                      = $::ipaddress,
  $cinder_iscsi_ip_addr                     = $::ipaddress_lo,
  $vncserver_listen                         = $::ipaddress,
  $quantum_host_address                     = $::ipaddress,
  $rabbit_host                              = $::ipaddress,
  # MySQL
  $db_type                                  = 'mysql',
  $mysql_bind_address                       = '0.0.0.0',
  $mysql_account_security                   = true,
  $allowed_hosts                            = '%',
  $db_host                                  = '127.0.0.1',
  $manage_mysql_server                      = true,
  # Credentials
  $admin_email                              = 'root@localhost',
  $rabbit_user                              = 'nova',
  $rabbit_virtual_host                      = '/',
  $quantum_admin_tenant_name                = 'services',
  $quantum_admin_username                   = 'quantum',
  $keystone_admin_user                      = 'admin',
  $keystone_admin_tenant                    = 'admin',
  $keystone_db_user                         = 'keystone',
  $keystone_db_dbname                       = 'keystone',
  $glance_db_user                           = 'glance',
  $glance_db_dbname                         = 'glance',
  $glance_user_password                     = 'glance_dba',
  $nova_db_user                             = 'nova',
  $nova_db_dbname                           = 'nova',
  $nova_admin_tenant                        = 'services',
  $nova_admin_user                          = 'nova',
  # Service Options
  $horizon                                  = true,
  $libvirt_type                             = 'kvm',
  $swift                                    = false,
  $purge_nova_config                        = false, # purge is known to be buggy
  $cinder                                   = true,
  $cinder_db_user                           = 'cinder',
  $cinder_db_dbname                         = 'cinder',
  $cinder_volumes_dir                       = '/etc/cinder/volumes',
  $cinder_volume_group                      = 'cinder-volumes',
  $quantum                                  = true,
  $quantum_db_user                          = 'quantum',
  $quantum_db_dbname                        = 'quantum_linux_bridge',
  $linux_bridge                             = true,
  $linux_bridge_tenant_network_type         = 'vlan',
  $linux_bridge_network_vlan_ranges         = "physnet1:1000:2999",
  $linux_bridge_physical_interface          = 'eth1',
  $linux_bridge_physical_interface_mappings = 'physnet1:eth1',
  $region                                   = 'RegionOne',
  $verbose                                  = false
) {


$quantum_sql_connection    = "mysql://${quantum_db_user}:${quantum_db_password}@${db_host}/${quantum_db_dbname}?charset=utf8"
$rabbit_connection = $rabbit_host

$keystone_host_public    = $keystone_host_address
$keystone_host_internal  = $keystone_host_address
$keystone_auth_url       = "http://${keystone_host_public}:5000/v2.0/"

$glance_host_public   = $glance_host_address
$glance_host_internal = $glance_host_address

$quantum_host_public   = $quantum_host_address
$quantum_host_internal = $quantum_host_address

$fixed_network_range = undef # Unused with Quantum

$cinder_host_public   = $cinder_host_address
$cinder_host_internal = $cinder_host_address

$nova_host_public    = $nova_host_address
$nova_host_internal  = $nova_host_address
$nova_sql_connection = "mysql://${nova_db_user}:${nova_db_password}@${db_host}/nova"
$quantum_server_host = $nova_host_address

  class { 'openstack::db::mysql':
    manage_mysql_server    => $manage_mysql_server,
    mysql_root_password    => $mysql_root_password,
    mysql_bind_address     => $mysql_bind_address,
    mysql_account_security => $mysql_account_security,
    keystone_db_user       => $keystone_db_user,
    keystone_db_password   => $keystone_db_password,
    keystone_db_dbname     => $keystone_db_dbname,
    glance_db_user         => $glance_db_user,
    glance_db_password     => $glance_db_password,
    glance_db_dbname       => $glance_db_dbname,
    nova_db_user           => $nova_db_user,
    nova_db_password       => $nova_db_password,
    nova_db_dbname         => $nova_db_dbname,
    cinder                 => $cinder,
    cinder_db_user         => $cinder_db_user,
    cinder_db_password     => $cinder_db_password,
    cinder_db_dbname       => $cinder_db_dbname,
    quantum                => $quantum,
    quantum_db_user        => $quantum_db_user,
    quantum_db_password    => $quantum_db_password,
    quantum_db_dbname      => $quantum_db_dbname,
    allowed_hosts          => $allowed_hosts,
    enabled                => $enabled,
  }

  Class['openstack::db::mysql'] -> Class['openstack::keystone']
  Class['openstack::db::mysql'] -> Class['openstack::glance']

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
    nova_user_password    => $nova_user_password,
    cinder                => $cinder,
    cinder_user_password  => $cinder_db_password,
    quantum               => $quantum,
    quantum_user_password => $quantum_admin_password,
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
    quantum_public_address   => $quantum_server_host,
    quantum_internal_address => $quantum_server_host,
    quantum_admin_address    => $quantum_server_host,
  }

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

  $enabled = true
  ######## NOVA ###########
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
    enabled       => false,
    virtual_host  => $rabbit_virtual_host,
  }

  # Configure Nova
  class { 'nova':
    sql_connection         => $nova_sql_connection,
    rabbit_userid          => $rabbit_user,
    rabbit_password        => $rabbit_password,
    rabbit_virtual_host    => $rabbit_virtual_host,
    image_service          => 'nova.image.glance.GlanceImageService',
    glance_api_servers     => "${glance_host_public}:9292",
    verbose                => $verbose,
    rabbit_host            => $rabbit_connection,
    nova_admin_tenant_name => $nova_admin_tenant,
    nova_admin_user        => $nova_admin_user,
    nova_admin_password    => $nova_user_password,
  }

  # Configure nova-api
  class { 'nova::api':
    enabled           => $enabled,
    admin_password    => $nova_user_password,
    auth_host         => $keystone_host_public,
  }

  class { 'nova::vncproxy':
    enabled => true,
    host    => $nova_host_internal,
  }

  class { 'nova::compute::quantum':
    # DODCS Begin
    libvirt_vif_driver => 'nova.virt.libvirt.vif.QuantumLinuxBridgeVIFDriver',
    linuxnet_interface_driver => 'nova.network.linux_net.QuantumLinuxBridgeInterfaceDriver',
    # DODCS End
  }
  # DODCS

  # Set up Quantum
  class { 'quantum':
    verbose          => $verbose,
    debug            => $verbose,
    rabbit_host      => $rabbit_host, # DODCS
    rabbit_user      => $rabbit_user,
    rabbit_password  => $rabbit_password,
    core_plugin      => 'quantum.plugins.linuxbridge.lb_quantum_plugin.LinuxBridgePluginV2', # DODCS
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
    quantum_username     => $quantum_admin_username,
    quantum_password     => $quantum_admin_password,
    quantum_admin_tenant => $quantum_admin_tenant_name,
    keystone_auth_url    => $keystone_auth_url,
    interface_driver     => 'quantum.agent.linux.interface.BridgeInterfaceDriver',
    use_namespaces       => 'False',
    debug                => $verbose,
    enabled              => false,
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
    enabled                 => false,
    debug                   => $verbose,
  }

  class { 'quantum::plugins::linuxbridge':
    sql_connection              => $quantum_sql_connection,
    tenant_network_type         => $linux_bridge_tenant_network_type,
    network_vlan_ranges         => $linux_bridge_network_vlan_ranges,
    physical_interface          => $linux_bridge_physical_interface,
    physical_interface_mappings => $linux_bridge_physical_interface_mappings,
  }

  class { 'quantum::agents::linuxbridge':
    enabled => false,
  }

  class { 'quantum::plugins::server':
    quantum_admin_password => $quantum_admin_password,
    quantum_db_password    => $quantum_db_password,
    mysql_root_pw          => $mysql_root_password,
    plugin                 => 'linuxbridge',
    vlan                   => $linux_bridge_physical_interface,
    user                   => $quantum_admin_username,
    tenant                 => $quantum_admin_tenant_name,
    auth_url               => $keystone_auth_url,
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
#      host    => $public_address,
      host    => '127.0.0.1',
      enabled => $enabled,
    }
  }
  class { 'cinder::base':
    rabbit_userid   => $rabbit_user,
    rabbit_host     => $rabbit_host,
    rabbit_password => $rabbit_password,
    sql_connection  => "mysql://${cinder_db_user}:${cinder_db_password}@${db_host}/${cinder_db_dbname}?charset=utf8",
    admin_user      => $cinder_db_user,
    admin_password  => $cinder_db_password,
    auth_host       => $keystone_host_public,
    auth_port       => '35357',
    auth_protocol   => 'http',
    signing_dirname => '/tmp/keystone-signing-cinder',
    rootwrap_config => '/etc/cinder/rootwrap.conf',
    volumes_dir     => $cinder_volumes_dir,
    state_path      => '/var/lib/cinder',
    lock_path       => '/var/lib/cinder/tmp',
    logdir          => '/var/log/cinder',
    rpc_backend     => 'cinder.openstack.common.rpc.impl_kombu',
    verbose         => $verbose,
  }

  class { 'cinder::api':
    keystone_password      => $keystone_admin_password,
    keystone_enabled       => true,
    keystone_tenant        => $keystone_admin_tenant,
    keystone_user          => $keystone_admin_user, 
    keystone_auth_host     => $keystone_host_public,
    keystone_auth_port     => '35357',
    keystone_auth_protocol => 'http',
    package_ensure         => 'present',
    bind_host              => '0.0.0.0',
    enabled                => true,
  }

  class { 'cinder::scheduler':
    package_ensure => present,
    enabled        => true,
  }

  class { 'cinder::volume':
    package_ensure => present,
    enabled        => true,
  }

  class { 'cinder::volume::iscsi':
    iscsi_ip_address => $cinder_iscsi_ip_addr,
    volume_group     => $cinder_volume_group,
    volumes_dir      => $cinder_volumes_dir,
  }


  # Install / configure nova-compute
  class { '::nova::compute':
    enabled                       => $enabled,
    vnc_enabled                   => $vnc_enabled,
    vncserver_proxyclient_address => $nova_host_internal,
    vncproxy_host                 => $nova_host_internal,
  }

  # Configure libvirt for nova-compute
  class { 'nova::compute::libvirt':
    libvirt_type     => $libvirt_type,
    vncserver_listen => $nova_host_internal,
  }

  ######## Horizon ########
  if ($horizon) {
    class { 'openstack::horizon':
      secret_key        => $secret_key,
#      cache_server_ip   => $cache_server_ip,
#      cache_server_port => $cache_server_port,
      swift             => $swift,
      quantum           => $quantum,
#      horizon_app_links => $horizon_app_links,
    }
  }

}
