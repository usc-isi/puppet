node 'bespin107.east.isi.edu' {

  class { 'openstack::compute':
  # Required Network
  $internal_address         => $internal_address,
  # Required Nova
  $nova_user_password       => $nova_user_password,
  # Required Rabbit
  $rabbit_password          => $rabbit_password,
  # DB
  $sql_connection           => $nova_sql_connection,
  # Network
  $public_interface         => $public_interface,
  $private_interface        => $private_interface,
# Nova Network (Ignored for Quatum?)
  $fixed_range              => $fixed_network_range,
  $network_manager          => 'nova.network.manager.FlatDHCPManager',
  $network_config           => {},
  $multi_host               => false,
  # Quantum
  $quantum                  => $quantum,
  $quantum_sql_connection   => "mysql://${quantum_db_user}:${quantum_db_password} @${db_host}/quantum_linux_bridge",
  $quantum_host             => $quantum_server_host,
  $quantum_user_password    => $quanum_db_password,
  $keystone_host            => $keystone_host_puublic,
  # Nova
  $purge_nova_config        => false,
  # Rabbit
  $rabbit_host              => $rabbit_host,
  $rabbit_user              => $rabbit_user,
  $rabbit_virtual_host      => $rabbit_virtual_host,
  # Glance
  $glance_api_servers       => $glance_host_public,
  # Virtualization
  $libvirt_type             => 'kvm',
  # VNC
  $vnc_enabled              => true,
  $vncproxy_host            => '127.0.0.1',
  $vncserver_listen         => false,
  # cinder / volumes
  $cinder                   => $cinder,
  $cinder_sql_connection    => "mysql://${cinder_db_user}:${cinder_db_password}@${db_host}/${cinder_db_name}",
  $manage_volumes           => true,
  $nova_volume              => 'cinder-volumes',
  $iscsi_ip_address         => '127.0.0.1',
  # General
  $migration_support        => false,
  $verbose                  => $verbose,
  $enabled                  => true,
  }
}
