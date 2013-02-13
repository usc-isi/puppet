# single-node-demo.pp
# Setup a single node as an automated testing host for lxc VMs.
# --------------------------------------------------------------------------- #
# This file may be used as a template for installing a DODCS OpenStack
# environment on a single host. The node definition includes both
# DODCS-specific and Puppet Labs OpenStack resources. These should be available
# on the DODCS Puppet master server.
#
# The class 'openstack::all' contains most of the configuration for OpenStack.
# The things to change in this file are:
#  o The string naming the node. (The template uses
#    'single-node-demo.example.com'.)
#  o Each variable set to an IP address, e.g. 10.0.0.1. Set as appropriate for
#    the target host.
#  o The value of 'fixed_range' defines the range of IP addresses for
#    instances.
#  o The devices for public and private interfaces
#  o The value of 'libvirt_type' can be either 'lxc' or 'kvm.'
#  o Check any variable that sets a user name or password. These include the
#    password for the MySQL root user, database user name and passwords for
#    OpenStack services, and passwords for other services, such as
#    rabbitmq-server.
#
# Some resources depend on others. To get Puppet to sequence things more-or-less
# correctly, the node definition adds three stages to the default "main"
# stage. The declarations before the "openstack::all" class are DODCS-specific
# classes that need to run before that class. The declarations after
# "openstack::all" are run after the main installation and configuration. 
# --------------------------------------------------------------------------- #

node 'bespin111.east.isi.edu' {

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

  notify { 'bespin111 configuration':
    message => 'Running configuration of bespin111.east.isi.edu',
  }

  class { 'mysql::python':  }

  class { 'mysql::ruby':
    package_name => 'ruby-mysql',
  }

  # package { 'python-nova':
  #  ensure => present,
  # }

  $quantum_admin_password  = 'servicepass'
  $quantum_admin_tenant_name = 'services'
  $quantum_admin_username  = 'quantum'
  $keystone_admin_token  = '999888777666'
  $keystone_db_password  = 'keystone_dba'
  $quantum_db_password   = 'servicepass'
  $use_cinder            = true
  $use_quantum           = true
  $use_horizon           = false
  $mysql_root_password    = 'dbsecrete'
  $linux_bridge                     = true
  $linux_bridge_tenant_network_type = 'vlan'
  $linux_bridge_network_vlan_ranges = "physnet1:1000:2999"
  $linux_bridge_physical_interface  = 'eth1'
  $linux_bridge_physical_interface_mappings = 'physnet1:eth1'
  $keystone_admin_user       = 'admin'
  $keystone_admin_tenant     = 'admin'
  $keystone_admin_password   = 'secrete'
  $keystone_controller_node  = '127.0.0.1'

  class { 'mysql': }
  # class { 'mysql::server':
  #   config_hash => {
  #     root_password => $mysql_root_password,
  #     bind_address => '0.0.0.0' },
  # }

# This uses Puppet Labs's OpenStack modules (maybe only for 2.7.x)
  class { 'openstack::all':
    public_address        => '10.0.5.11',
    public_interface      => eth0,
    private_interface     => eth1,
# What needs to be here? flat_network_bridge not used in quantum?
# Nothing needed here -- superseded by quantum.
    # network_config        => { flat_network_bridge => 'br100',
    #                            force_dhcp_release => false,
    #                            flat_injected => false,
    #                            flat_interface => eth1,
    #                            dhcpbridge  => '/usr/bin/nova-dhcpbridge',
    #                            dhcpbridge_flagfile => '/etc/nova/nova.conf' },
    fixed_range           => '10.111.0.0/24',
    mysql_root_password   => $mysql_root_password,
    rabbit_host           => '10.111.0.1',
    rabbit_password       => 'dbsecrete',
    admin_email           => 'admin@example.com',
    keystone_admin_user   => $keystone_admin_user,
    keystone_admin_tenant => $keystone_admin_tenant,
    keystone_auth_url     => 'http://127.0.0.1:5000/v2.0/',
    admin_password        => $keystone_admin_password,
    keystone_db_password  => $keystone_db_password,
    keystone_admin_token  => $keystone_admin_token,
    nova_db_password      => 'nova_secrete',
#    nova_user             => 'admin',
    nova_user_password    => 'secrete',
#    nova_tenant           => 'admin',
    glance_db_password    => 'glance_dba',
#    glance_user           => 'admin',
    glance_user_password  => 'secrete',
#    glance_tenant         => 'admin',
    purge_nova_config     => false,
    libvirt_type          => 'kvm',
#    nova_volume           => 'nova-volumes',
#    iscsi_ip_address      => '10.111.0.1',
    verbose               => true,
#    package_ensure        => 'present',
# "Vanilla"
    quantum_admin_password  =>   $quantum_admin_password,
    quantum_admin_tenant_name => $quantum_admin_tenant_name,
    quantum_admin_username  => $quantum_admin_username,
    quantum_user_password => $quantum_db_password,
    quantum_db_password   => $quantum_db_password, 
    secret_key            => 'dummy_secrete_key',
    cinder                => $use_cinder,
    quantum               => $use_quantum,
    horizon               => $use_horizon,
    linux_bridge          => $linux_bridge,
    linux_bridge_tenant_network_type => $linux_bridge_tenant_network_type,
    linux_bridge_network_vlan_ranges => $linux_bridge_network_vlan_ranges,
    linux_bridge_physical_interface  => $linux_bridge_physical_interface,
    linux_bridge_physical_interface_mappings => $linux_bridge_physical_interface_mappings,
  }

#  Class['openstack::all'] -> Class['openstack::auth_file'] -> File['test_nova.sh']
  Class['openstack::all'] -> Class['openstack::auth_file']

  class { 'openstack::auth_file':
    admin_user           => $keystone_admin_user,
    admin_tenant         => $keystone_admin_tenant,
    controller_node      => $keystone_controller_node,
    admin_password       => $keystone_admin_password,
    keystone_admin_token => $keystone_admin_token,
  }

  # Values needed in test_nova.sh.erb
  $rc_file_path = '/root/openrc'
  $image_type   = 'cirros'
  $sleep_time   = 600
  $floating_ip  = false
  $net          = 'net1'
  $subnet       = '10.0.0.0/24' # Is this reasonable for a test?
  $quantum      = $use_quantum # Just for the script ERB.
  file { 'test_nova.sh':
    ensure  => present,
    path    => '/root/vanilla-experiments/test_nova.sh',
    content => template('openstack/test_nova.sh.erb'),
#    source => 'puppet:///modules/openstack/nova_test.sh',
    mode    => '0750',
 }
}
