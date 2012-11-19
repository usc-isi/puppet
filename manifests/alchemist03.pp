
node 'alchemist03.east.isi.edu' {
  import 'defaults.pp'
  notify { 'alchemist03 configuration':
    message => 'Running configuration of alchemist03.east.isi.edu',
  }

  class { 'dodcs-postproc':  }
  
#+=- Begin "Roll-Our-Own" -=+=
  
 # include dodcs-openstack
 # include mysql
  # class { 'mysql':
  #   enabled => false,
  #   shell   => '/bin/false',
  #   home    => '/var/lib/mysql',
  #   service => 'mysqld',
  # }

  class { 'dodcs-repository': }
  
#  class { 'mysql': }

  # package { 'dodcs-mysql-server':
  #   # Get this in before openstack::all tries to run it.
  #   name   => 'mysql-server',
  #   ensure => present,
  # }

  class { 'mysql::python':  }

  class { 'mysql::ruby':
    package_name => 'ruby-mysql',
  }
  
  # class { 'mysql::server':
  #   config_hash => { 'root_password' => 'd0dcSdba' }
  # }

  # class { 'rabbitmq': }

  # class { 'dodcs-openstack': }

#+=- End "Roll-Our-Own" -=+=

  package { 'dodcs-openstack':
    ensure => present,
  }

# This uses Puppet Labs's OpenStack modules (maybe only for 2.7.x)
  class { 'openstack::all':
    public_address        => '65.114.169.119',
    public_interface      => eth0,
    private_interface     => br100,
#  where to put? flat_interface = eth1
    network_config        => { flat_network_bridge => 'br100',
                               force_dhcp_release => true,
                               flat_injected => false,
                               flat_interface => eth1,
                               dhcpbridge  => '/usr/local/nova/bin/nova-dhcpbridge',
                               dhcpbridge_flagfile => '/etc/nova/nova.conf' },
    fixed_range           => '10.77.0.0/24',
    mysql_root_password   => 'd0dcSdba',
    rabbit_host           => '10.77.0.1',
    rabbit_password       => 'd0dcSdba',
    admin_email           => 'cward@isi.edu',
    admin_password        => 'secrete',
    keystone_db_password  => 'keystone_dba',
    keystone_admin_token  => '999888777666',
    nova_db_password      => 'nova_dba',
    nova_user             => 'admin',
    nova_user_password    => 'secrete',
    nova_tenant           => 'admin',
    glance_db_password    => 'glance_dba',
    glance_user           => 'admin',
    glance_user_password  => 'secrete',
    glance_tenant         => 'admin',
    purge_nova_config     => false,
    libvirt_type          => 'kvm',
    nova_volume           => 'nova-volumes',
    iscsi_ip_address      => '10.77.0.1',
    verbose               => true,
    package_ensure        => 'latest',
  }

  # This is supposed to tell Puppet how to sequence these classes and packages.
  # The should go left-to-right.
# Package['dodcs-mysql-server'] ->
  Class['dodcs-repository'] ->  Package['dodcs-openstack'] -> Class['mysql::python'] -> Class['mysql::ruby'] -> Class['openstack::all'] -> Class['dodcs-postproc']

}
