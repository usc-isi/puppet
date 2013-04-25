#
# Example defines a two-node setup.
#
# Controller Node: nova services, including nova-compute, quantum, cinder,
# glance, keystone, and MySQL database.
#
# Compute Node: nova-compute and quantum-linuxbridge-agent.
#
# ------------------------------------------------------------------------- #

$services_two_nodes = '10.0.5.8'

node /nova-controller-node/ {

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

  notify { "$::fqdn":
    message => "Running configuration of $::fqdn; services at $services_two_nodes",
  }

  class { 'isi::params':
    rabbit_host                              => $services_two_nodes,
    quantum_server_host                      => $services_two_nodes,
    db_host                                  => '127.0.0.1',
    keystone_host_address                    => $services_two_nodes,
    cinder_host_address                      => $services_two_nodes,
    nova_host_address                        => $services_two_nodes,
    quantum_host_address                     => $services_two_nodes,
    cinder_iscsi_ip_addr                     => $services_two_nodes,
    glance_host_address                      => $services_two_nodes,
    public_interface                         => 'eth0',
    private_interface                        => 'eth1',
    vncserver_listen                         => $::ipaddress_eth0,
    horizon                                  => true,
    linux_bridge                             => true,
    linux_bridge_tenant_network_type         => 'vlan',
    linux_bridge_network_vlan_ranges         => 'physnet1,physnet2:1000:2999',
    linux_bridge_physical_interface          => 'eth0,eth1',
    linux_bridge_physical_interface_mappings => 'physnet1:eth0,physnet2:eth1',
    }

  class {'isi::mysql': }
  class {'isi::keystone': }
  class {'isi::glance': }
  class {'isi::nova-controller':
    quantum_agents_enabled => true,
    nova_compute           => true, # Run a compute node, too.
  }
  class {'isi::cinder':
    rpc_backend          => 'cinder.openstack.common.rpc.impl_kombu',
    iam_cinder_master    => true,
    load_python_keystone => false, # Because same node as keystone
  }
  class {"isi::auth_file": }

  Class['isi::params'] -> Class['isi::mysql'] -> Class['isi::keystone']
  Class['isi::keystone'] -> Class['isi::glance'] -> Class['isi::nova-controller']
  Class['isi::nova-controller'] -> Class['isi::cinder']
  Class['isi::cinder'] -> Class['isi::auth_file']
}

node /compute-node/ {

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
    
  notify { "$::fqdn":
    message => "Running configuration of $::fqdn",
  }

  class { 'isi::params':
    rabbit_host                              => $services_two_nodes,
    quantum_server_host                      => $services_two_nodes,
    db_host                                  => $services_two_nodes,
    keystone_host_address                    => $services_two_nodes,
    cinder_host_address                      => $services_two_nodes,
    nova_host_address                        => $services_two_nodes,
    quantum_host_address                     => $services_two_nodes,
    cinder_iscsi_ip_addr                     => $services_two_nodes,
    glance_host_address                      => $services_two_nodes,
    vncserver_listen                         => $::ipaddress,
    linux_bridge                             => true,
    linux_bridge_tenant_network_type         => 'vlan',
    linux_bridge_network_vlan_ranges         => 'physnet1,physnet2:1000:2999',
    linux_bridge_physical_interface          => 'eth0,eth1',
    linux_bridge_physical_interface_mappings => 'physnet2:eth0,physnet1:eth1',
  }

  class {'isi::compute-node':
    internal_address => "$::ipaddress",
  }
  
  class {"isi::auth_file": }

  Class['isi::params'] ->  Class['isi::compute-node'] ->  Class['isi::auth_file']
}
