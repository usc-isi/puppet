# cst155.pp
# Setup cst155 as automated testing host.

node 'cst155.east.isi.edu' {
  import 'defaults.pp'
  notify { 'cst155 configuration':
    message => 'Running configuration of cst155.east.isi.edu',
  }

  class { 'dodcs-repository':
    notify => Package['dodcs-openstack'],
  }

  package { 'dodcs-openstack':
    ensure   => latest,
    require => Class['dodcs-repository'],
  }

  # class { 'mysql::python':  }

  # class { 'mysql::ruby':
  #   package_name => 'ruby-mysql',
  # }

# # This uses Puppet Labs's OpenStack modules (maybe only for 2.7.x)
#   class { 'openstack::all':
#     public_address        => '65.123.202.103',
#     public_interface      => eth0,
#     private_interface     => eth1,
# #  where to put? flat_interface = eth1
#     network_config        => { flat_network_bridge => 'br100',
#                                force_dhcp_release => true,
#                                flat_injected => false,
#                                flat_interface => eth1,
#                                dhcpbridge  => '/usr/local/nova/bin/nova-dhcpbridge',
#                                dhcpbridge_flagfile => '/etc/nova/nova.conf' },
#     fixed_range           => '10.66.0.0/24',
#     mysql_root_password   => 'd0dcSdba',
#     rabbit_host           => '10.66.0.1',
#     rabbit_password       => 'd0dcSdba',
#     admin_email           => 'cward@isi.edu',
#     admin_password        => 'secrete',
#     keystone_db_password  => 'keystone_dba',
#     keystone_admin_token  => '999888777666',
#     nova_db_password      => 'nova_dba',
#     nova_user             => 'admin',
#     nova_user_password    => 'secrete',
#     nova_tenant           => 'admin',
#     glance_db_password    => 'glance_dba',
#     glance_user           => 'admin',
#     glance_user_password  => 'secrete',
#     glance_tenant         => 'admin',
#     purge_nova_config     => false,
#     libvirt_type          => 'kvm',
#     nova_volume           => 'nova-volumes',
#     iscsi_ip_address      => '10.66.0.1',
#     verbose               => true,
#     package_ensure        => 'latest',
#   }

#   class { 'dodcs-postproc':  }

#   # This is supposed to tell Puppet how to sequence these classes and packages.
#   # The should go left-to-right.
# # Package['dodcs-mysql-server'] ->
#   Class['dodcs-repository'] ->  Package['dodcs-openstack'] -> Class['mysql::python'] -> Class['mysql::ruby'] -> Class['openstack::all'] -> Class['dodcs-postproc']

}
