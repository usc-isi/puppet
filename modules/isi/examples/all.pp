#
# Setup a vanilla single node Openstack Folsom using the isi::params,
# isi::mysql, isi::keystone, isi::glance, isi::cinder, and isi::nova-controller
# classes.
#
# The isi::nova-contoller class is also used to setup just a nova-controller
# without the other services. This example passes the flags
# 'quantum_agents_enabled' and 'nova_compute' as true.  The other node types
# are included to capture those serivces also.
# ------------------------------------------------------------------------- #

node /all-in-one-node/ {

  stage { 'last':
    require  => Stage['main'],
  }

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
    message => "Running configuration of $::fqdn; services at '10.0.0.1'",
  }

  class { 'isi::params':
    db_type                                  => 'mysql',
    db_host                                  => '127.0.0.1',
    mysql_root_password                      => 'dba_password',
    rabbit_host                              => '10.0.0.1',
    quantum_server_host                      => '10.0.0.1',
    keystone_host_address                    => '10.0.0.1',
    cinder_host_address                      => '10.0.0.1',
    nova_host_address                        => '10.0.0.1',
    quantum_host_address                     => '10.0.0.1',
    cinder_iscsi_ip_addr                     => '10.0.0.1',
    glance_host_address                      => '10.0.0.1',
    public_interface                         => 'eth0',
    private_interface                        => 'eth1',
    vncserver_listen                         => '0.0.0.0',
    dnsmasq_dns_server                       => '65.114.168.20',
    horizon                                  => true,
    purge_nova_config                        => false,
    linux_bridge                             => true,
    linux_bridge_tenant_network_type         => 'vlan',
    linux_bridge_network_vlan_ranges         => 'physnet1:1000:2999',
    linux_bridge_physical_interface_mappings => 'physnet1:eth1',
    }

  class {'isi::mysql': }
  class {'isi::keystone': }
  class {'isi::glance': }
  class {'isi::nova-controller':
    quantum_agents_enabled => true, # Run quantum agents, too.
    nova_compute           => true, # Run a compute node, too.
  }

  class {'isi::cinder':
    stage                => last,
    rpc_backend          => 'cinder.openstack.common.rpc.impl_kombu',
    iam_cinder_master    => true,
    load_python_keystone => false, # Because same node as keystone
    require              => [ Class['isi::mysql'], Class['isi::keystone'] ],
  }

  class {"isi::auth_file":
      stage => last,
  }

  Class['isi::params'] -> Class['isi::mysql'] -> Class['isi::keystone']
  Class['isi::keystone'] -> Class['isi::glance'] -> Class['isi::nova-controller']
  Class['isi::nova-controller'] -> Class['isi::cinder']
  Class['isi::cinder'] -> Class['isi::auth_file']


}
